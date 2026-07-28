import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_file_actions.dart';
import '../../../../core/widgets/swipe_action_button.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../config/routes/entity/routes.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/usecases/change_task_status_usecase.dart';
import '../../domain/task_status_policy.dart';
import '../bloc/task_create_bloc.dart';

/// Vazifa tafsilotlari — "Batafsil" (Figma: o'qish rejimidagi forma
/// maydonlari + biriktirilgan fayllar + rad etish sababi + holat tugmalari).
/// Holat o'zgargach `true` bilan yopiladi (ro'yxat qayta yuklanadi).
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});

  final int taskId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCreateBloc>(
      create: (_) =>
          getIt<TaskCreateBloc>()..add(TaskCreateDetailRequested(taskId)),
      child: _TaskDetailView(taskId: taskId),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView({required this.taskId});

  final int taskId;

  List<TaskStatusAction> _actions(
    TaskDetail detail,
    TaskStatusPermissionContext? permissionContext,
  ) => TaskStatusPolicy.actions(
    status: detail.status,
    assigneeId: detail.assigneeId,
    context: permissionContext,
  );

  Future<void> _onAction(BuildContext context, TaskStatusAction action) async {
    final bloc = context.read<TaskCreateBloc>();
    if (action == TaskStatusAction.rejected) {
      final result = await showTaskRejectDialog(context);
      if (result != null) {
        bloc.add(
          TaskCreateStatusSubmitted(
            ChangeTaskStatusParams(
              id: taskId,
              status: TaskStatus.rejected,
              reason: result.reason,
              photoPaths: result.photoPaths,
            ),
          ),
        );
      }
      return;
    }

    bloc.add(
      TaskCreateStatusSubmitted(
        ChangeTaskStatusParams(
          id: taskId,
          status: TaskStatusPolicy.target(action),
        ),
      ),
    );
  }

  Future<void> _editTask(BuildContext context) async {
    final updated = await context.pushNamed<bool>(
      Routes.taskEdit.name,
      pathParameters: {'id': '$taskId'},
    );
    if (updated == true && context.mounted) {
      context.read<TaskCreateBloc>().add(TaskCreateDetailRequested(taskId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<TaskCreateBloc, TaskCreateState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) {
        switch (state.submitStatus) {
          case TaskSubmitStatus.success:
            AppToast.showSuccess(context, title: l10n.taskStatusUpdated);
            Navigator.of(context).maybePop(true);
          case TaskSubmitStatus.failure:
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.submitFailure?.message,
            );
          case TaskSubmitStatus.idle:
          case TaskSubmitStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: l10n.taskDetailTitle),
              Expanded(
                child: BlocBuilder<TaskCreateBloc, TaskCreateState>(
                  buildWhen: (p, c) =>
                      p.detail != c.detail ||
                      p.detailLoading != c.detailLoading ||
                      p.attachments != c.attachments ||
                      p.permissionContext != c.permissionContext ||
                      p.submitStatus != c.submitStatus,
                  builder: (context, state) {
                    final detail = state.detail;
                    if (detail == null) {
                      if (state.detailLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _ErrorState(
                        onRetry: () => context.read<TaskCreateBloc>().add(
                          TaskCreateDetailRequested(taskId),
                        ),
                      );
                    }
                    final submitting =
                        state.submitStatus == TaskSubmitStatus.submitting;
                    final actions = _actions(detail, state.permissionContext);
                    final editScope = TaskEditPolicy.scope(
                      status: detail.status,
                      context: state.permissionContext,
                      createdById: detail.createdById,
                    );
                    return Column(
                      children: [
                        Expanded(
                          child: _DetailBody(
                            detail: detail,
                            attachments: state.attachments,
                          ),
                        ),
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (editScope != TaskEditScope.none)
                                  _TaskEditButton(
                                    label:
                                        editScope == TaskEditScope.deadlineOnly
                                        ? l10n.taskActionEditDeadline
                                        : l10n.taskEditTitle,
                                    loading: submitting,
                                    onTap: () => _editTask(context),
                                  ),
                                for (final action in actions)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: _TaskSwipeAction(
                                      action: action,
                                      enabled: !submitting,
                                      onCompleted: () =>
                                          _onAction(context, action),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Kontent ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail, required this.attachments});

  final TaskDetail detail;
  final List<TaskAttachmentInfo> attachments;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final estimated = detail.estimatedMinutes ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          _ReadOnlyField(
            label: l10n.taskCreateFieldProject,
            value: detail.projectInfo,
          ),
          _ReadOnlyField(label: l10n.taskCreateFieldName, value: detail.title),
          if (detail.description.isNotEmpty)
            _ReadOnlyField(
              label: l10n.taskCreateFieldDescription,
              value: detail.description,
              multiline: true,
            ),
          _ReadOnlyField(
            label: l10n.taskCreateFieldPriority,
            value: _priorityLabel(detail.priority, l10n),
          ),
          if (detail.type != null)
            _ReadOnlyField(
              label: l10n.taskCreateFieldType,
              value: _typeLabel(detail.type!, l10n),
            ),
          _AssigneeField(detail: detail),
          if (detail.taskPrice.isNotEmpty)
            _ReadOnlyField(
              label: l10n.taskCreateFieldPrice,
              value: Formatters.formatAmount(detail.taskPrice),
              alignEnd: true,
            ),
          if (detail.penaltyPercentage.isNotEmpty)
            _ReadOnlyField(
              label: l10n.taskCreateFieldPenalty,
              value: detail.penaltyPercentage,
            ),
          Row(
            children: [
              Expanded(
                child: _ReadOnlyField(
                  label: l10n.taskCreateFieldDeadline,
                  value: _fmtDate(detail.deadline),
                  icon: Assets.icons.icCalendar,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _ReadOnlyField(
                  label: l10n.taskCreateFieldTime,
                  value: _fmtClock(detail.deadline),
                  icon: Assets.icons.icTuilconTime,
                ),
              ),
            ],
          ),
          if (estimated > 0)
            _ReadOnlyField(
              label: l10n.taskCreateFieldEstimated,
              value:
                  '${estimated ~/ 60}:'
                  '${(estimated % 60).toString().padLeft(2, '0')}',
              icon: Assets.icons.icTuilconTime,
            ),
          if (attachments.isNotEmpty) ...[
            SizedBox(height: 4.h),
            l10n.taskCreateFieldFiles.s(15.sp).w(800).c(colors.textStrong),
            for (final file in attachments) _AttachmentRow(file: file),
          ],
          if (detail.rejectionReason.isNotEmpty ||
              detail.rejectionFiles.isNotEmpty) ...[
            SizedBox(height: 4.h),
            l10n.taskDetailRejectReason.s(15.sp).w(800).c(colors.textStrong),
            _RejectionBox(
              reason: detail.rejectionReason,
              fileUrls: detail.rejectionFiles,
            ),
          ],
        ],
      ),
    );
  }
}

/// O'qish rejimidagi maydon: yorliq + chegarali quti ichida qiymat.
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.multiline = false,
    this.alignEnd = false,
    this.icon,
  });

  final String label;
  final String value;
  final bool multiline;
  final bool alignEnd;
  final SvgGenImage? icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = (value.isEmpty ? '—' : value)
        .s(13.sp)
        .w(700)
        .h(20 / 13)
        .c(colors.textStrong)
        .copyWith(
          maxLines: multiline ? null : 1,
          overflow: multiline ? null : TextOverflow.ellipsis,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: label.s(11.sp).w(700).c(colors.textSub),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundBase,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: alignEnd
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: text,
                    ),
                  ),
                  if (icon != null) ...[
                    SizedBox(width: 4.w),
                    icon!.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AssigneeField extends StatelessWidget {
  const _AssigneeField({required this.detail});

  final TaskDetail detail;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: l10n.taskCreateFieldAssigner.s(11.sp).w(700).c(colors.textSub),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundBase,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: Row(
              children: [
                TuiAvatar(
                  initial: detail.assigneeName,
                  avatarUrl: detail.assigneeAvatar,
                  size: 32,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (detail.assigneeName.isEmpty ? '—' : detail.assigneeName)
                          .s(13.sp)
                          .w(700)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (detail.assigneePosition.isNotEmpty)
                        detail.assigneePosition
                            .s(11.sp)
                            .w(500)
                            .c(colors.textSub)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Biriktirilgan fayl qatori: hujjat ikonkasi + fayl nomi.
class _AttachmentRow extends StatelessWidget {
  const _AttachmentRow({required this.file});

  final TaskAttachmentInfo file;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Center(
              child: Assets.icons.icDocument.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: file.name
              .s(13.sp)
              .w(700)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        AppFileActions(
          url: file.fileUrl,
          openLabel: AppLocalizations.of(context).commonOpenFile,
          downloadLabel: AppLocalizations.of(context).commonDownloadFile,
          errorTitle: AppLocalizations.of(context).commonError,
        ),
      ],
    );
  }
}

/// Rad etish sababi qutisi: skrinshotlar + matn.
class _RejectionBox extends StatelessWidget {
  const _RejectionBox({required this.reason, required this.fileUrls});

  final String reason;
  final List<String> fileUrls;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundBase,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (fileUrls.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final url in fileUrls)
                      InkWell(
                        onTap: () => _showRejectionImage(context, url),
                        borderRadius: BorderRadius.circular(8.r),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            url,
                            width: 64.w,
                            height: 64.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => DecoratedBox(
                              decoration: BoxDecoration(
                                color: colors.backgroundElevation1,
                              ),
                              child: SizedBox(width: 64.w, height: 64.w),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],
              if (reason.isNotEmpty)
                reason.s(13.sp).w(500).h(20 / 13).c(colors.textStrong),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showRejectionImage(BuildContext context, String url) {
  final colors = AppColors.of(context);
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: colors.backgroundBase,
      insetPadding: EdgeInsets.all(16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 0.9.sw, maxHeight: 0.8.sh),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => SizedBox(width: 64.w, height: 64.w),
          ),
        ),
      ),
    ),
  );
}

// ── Holat tugmalari ──────────────────────────────────────────────────────

class _TaskSwipeAction extends StatelessWidget {
  const _TaskSwipeAction({
    required this.action,
    required this.enabled,
    required this.onCompleted,
  });

  final TaskStatusAction action;
  final bool enabled;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final (label, handleColor) = switch (action) {
      TaskStatusAction.inProgress => (
        l10n.taskActionInProgress,
        colors.taskStatusInProgress,
      ),
      TaskStatusAction.done => (l10n.taskActionMarkDone, colors.taskStatusDone),
      TaskStatusAction.production => (
        l10n.taskActionProduction,
        colors.taskStatusProduction,
      ),
      TaskStatusAction.checked => (
        l10n.taskActionChecked,
        colors.taskStatusChecked,
      ),
      TaskStatusAction.rejected => (
        l10n.taskActionRejected,
        colors.taskStatusRejected,
      ),
    };

    return SwipeActionButton(
      label: label,
      onCompleted: onCompleted,
      enabled: enabled,
      trackColor: colors.backgroundElevation1Alt,
      handleColor: handleColor,
      handleOnRight: action == TaskStatusAction.rejected,
      icon: CustomPaint(
        size: Size(18.w, 14.w),
        painter: _DoubleCaretPainter(
          color: colors.textWhite,
          pointLeft: action == TaskStatusAction.rejected,
        ),
      ),
    );
  }
}

class _TaskEditButton extends StatelessWidget {
  const _TaskEditButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: loading ? null : onTap,
        icon: Assets.icons.icArrowRight.svg(
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
        ),
        label: label.s(15.sp).w(800).c(colors.textAccent),
      ),
    );
  }
}

/// Ikki qavat chevron (» / «) — assetlarda yo'q, shu bois chizib qo'yilgan.
class _DoubleCaretPainter extends CustomPainter {
  _DoubleCaretPainter({required this.color, required this.pointLeft});

  final Color color;
  final bool pointLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final h = size.height;
    final half = size.width / 2;

    void caret(double startX) {
      final path = Path();
      if (pointLeft) {
        path
          ..moveTo(startX + half * 0.7, 0)
          ..lineTo(startX, h / 2)
          ..lineTo(startX + half * 0.7, h);
      } else {
        path
          ..moveTo(startX, 0)
          ..lineTo(startX + half * 0.7, h / 2)
          ..lineTo(startX, h);
      }
      canvas.drawPath(path, paint);
    }

    caret(0);
    caret(half);
  }

  @override
  bool shouldRepaint(_DoubleCaretPainter old) =>
      old.color != color || old.pointLeft != pointLeft;
}

// ── Rad etish varag'i ────────────────────────────────────────────────────

typedef TaskRejectResult = ({String reason, List<String> photoPaths});

/// Figma reject dialogi: majburiy sabab + ixtiyoriy rasmlar.
/// `null` — bekor qilindi.
Future<TaskRejectResult?> showTaskRejectDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<TaskRejectResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.backgroundBase,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => const _RejectSheet(),
  );
}

class _RejectSheet extends StatefulWidget {
  const _RejectSheet();

  @override
  State<_RejectSheet> createState() => _RejectSheetState();
}

class _RejectSheetState extends State<_RejectSheet> {
  final _reasonCtrl = TextEditingController();
  final List<PlatformFile> _photos = [];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result == null) return;
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _photos.add(f);
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).commonError,
      );
    }
  }

  void _confirm() {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).taskRejectSubtitle,
      );
      return;
    }
    Navigator.of(
      context,
    ).pop((reason: reason, photoPaths: [for (final f in _photos) f.path!]));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: colors.textStrong,
      height: 20 / 13,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 8.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.strokeSoft,
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: SizedBox(width: 24.w, height: 3.h),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: l10n.taskRejectTitle
                .s(19.sp)
                .w(800)
                .h(28 / 19)
                .c(colors.textStrong),
          ),
          SizedBox(height: 4.h),
          Center(
            child: l10n.taskRejectSubtitle
                .s(15.sp)
                .w(500)
                .h(24 / 15)
                .c(colors.textSub),
          ),
          SizedBox(height: 16.h),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.strokeSub, width: 1.w),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: SizedBox(
                width: double.infinity,
                child: SizedBox(
                  height: 94.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final photo in _photos) ...[
                              _PhotoThumb(
                                photo: photo,
                                onRemove: () =>
                                    setState(() => _photos.remove(photo)),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            _AddPhotoTile(onTap: _pickPhotos),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Expanded(
                        child: TextField(
                          controller: _reasonCtrl,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          style: style,
                          cursorColor: colors.accentSub,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration.collapsed(
                            hintText: l10n.taskRejectHint,
                            hintStyle: style.copyWith(color: colors.textSub),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    height: 52.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.icClose.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.textStrong,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        l10n.taskDeleteCancel
                            .s(15.sp)
                            .w(800)
                            .c(colors.textStrong),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: InkWell(
                  onTap: _confirm,
                  borderRadius: BorderRadius.circular(16.r),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.errorStrong,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: SizedBox(
                      height: 52.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.icons.icTrash.svg(
                            width: 16.w,
                            height: 16.w,
                            colorFilter: ColorFilter.mode(
                              colors.textWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          l10n.taskRejectConfirm
                              .s(15.sp)
                              .w(800)
                              .c(colors.textWhite),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.photo, required this.onRemove});

  final PlatformFile photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(
            File(photo.path!),
            width: 40.w,
            height: 40.w,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: -6.h,
          right: -6.w,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.backgroundElevation1,
                shape: BoxShape.circle,
                border: Border.all(color: colors.strokeSub, width: 1.w),
              ),
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: Center(
                  child: Assets.icons.icClose.svg(
                    width: 10.w,
                    height: 10.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(
            child: Assets.icons.icPlus.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Yordamchilar ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 32.w),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          l10n.commonError
              .s(14.sp)
              .w(500)
              .c(colors.textSub)
              .a(TextAlign.center),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
          ),
        ],
      ),
    );
  }
}

String _priorityLabel(TaskPriority p, AppLocalizations l10n) => switch (p) {
  TaskPriority.low => l10n.taskPriorityLow,
  TaskPriority.medium => l10n.taskPriorityMedium,
  TaskPriority.high => l10n.taskPriorityHigh,
  TaskPriority.critical => l10n.taskPriorityCritical,
  TaskPriority.unknown => '',
};

String _typeLabel(TaskType t, AppLocalizations l10n) => switch (t) {
  TaskType.bug => l10n.taskTypeBug,
  TaskType.feature => l10n.taskTypeFeature,
  TaskType.extra => l10n.taskTypeAddition,
  TaskType.research => l10n.taskTypeResearch,
};

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

String _fmtClock(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)}';
}
