import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_file_actions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/new_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_form_options.dart';
import '../../domain/task_status_policy.dart';
import '../../domain/usecases/submit_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../bloc/task_create_bloc.dart';

/// Ochilib turgan dropdown maydoni (bir vaqtda faqat bittasi).
enum _Field { none, project, priority, type, assigner, positions }

/// Vazifa qo'shish/tahrirlash formasi (`Routes.taskCreate` / `Routes.taskEdit`).
/// [taskId] berilsa forma tahrirlash rejimida ochiladi: detal + fayllar
/// yuklanib maydonlar oldindan to'ldiriladi, saqlash `PATCH` yuboradi.
class TaskCreatePage extends StatelessWidget {
  const TaskCreatePage({super.key, this.taskId});

  final int? taskId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskCreateBloc>(
      create: (_) {
        final bloc = getIt<TaskCreateBloc>()
          ..add(const TaskCreateOptionsRequested());
        if (taskId != null) bloc.add(TaskCreateDetailRequested(taskId!));
        return bloc;
      },
      child: _TaskCreateView(taskId: taskId),
    );
  }
}

class _TaskCreateView extends StatefulWidget {
  const _TaskCreateView({this.taskId});

  final int? taskId;

  @override
  State<_TaskCreateView> createState() => _TaskCreateViewState();
}

class _TaskCreateViewState extends State<_TaskCreateView> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  final _sprintCtrl = TextEditingController();

  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    _Field.project: LayerLink(),
    _Field.priority: LayerLink(),
    _Field.type: LayerLink(),
    _Field.assigner: LayerLink(),
    _Field.positions: LayerLink(),
  };
  _Field _open = _Field.none;

  ProjectShort? _project;
  TaskPriority? _priority;
  TaskType? _type;
  ProjectMember? _assigner;
  Position? _position;
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;
  DateTime? _originalDeadline;
  TimeOfDay? _estimated;
  final List<PlatformFile> _files = [];

  bool get _isEdit => widget.taskId != null;

  TaskEditScope _editScope(TaskCreateState state) {
    if (!_isEdit) return TaskEditScope.full;
    final detail = state.detail;
    if (detail == null) return TaskEditScope.none;
    return TaskEditPolicy.scope(
      status: detail.status,
      context: state.permissionContext,
      createdById: detail.createdById,
    );
  }

  /// Detal maydonlari bir marta to'ldirildi (keyingi emitlarda qayta yozilmaydi).
  bool _prefilled = false;

  /// Loyiha `project-shorts`da topilmasa ko'rsatiladigan nom (`project_info`).
  String? _projectFallbackTitle;

  /// Saqlashda o'chiriladigan mavjud biriktirilgan fayl idlari.
  final List<int> _removedAttachmentIds = [];

  static const _priorities = [
    TaskPriority.low,
    TaskPriority.medium,
    TaskPriority.high,
    TaskPriority.critical,
  ];
  // Dizayn tartibi: Bug / Yangi funksiya / Qo'shimcha / Tadqiqot.
  static const _types = [
    TaskType.bug,
    TaskType.feature,
    TaskType.extra,
    TaskType.research,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _penaltyCtrl.dispose();
    _sprintCtrl.dispose();
    super.dispose();
  }

  // ── Dropdown ochish/yopish ────────────────────────────────────────────────

  void _toggle(_Field f) {
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == f ? _Field.none : f);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _onAssignerTap() {
    if (_project == null) {
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).taskCreateSelectProjectFirst,
      );
      return;
    }
    _toggle(_Field.assigner);
  }

  /// Oddiy tanlov (priority / type / position): qiymatni yozib, dropdown'ni yopadi.
  void _pick(VoidCallback assign) {
    setState(() {
      assign();
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _selectProject(ProjectShort p) {
    setState(() {
      _project = p;
      _assigner = null;
      _position = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
    context.read<TaskCreateBloc>().add(TaskCreateProjectSelected(p.id));
  }

  void _selectAssigner(ProjectMember m) {
    setState(() {
      _assigner = m;
      _position = _resolvePosition(m.position);
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  /// Topshiruvchining lavozimini "Kimlar uchun" ro'yxatidagi [Position] bilan
  /// bog'laydi; topilmasa xuddi shu nom bilan sintetik [Position] qaytaradi.
  Position _resolvePosition(String name) {
    for (final p in context.read<TaskCreateBloc>().state.positions) {
      if (p.name == name) return p;
    }
    return Position(id: 0, name: name);
  }

  // ── Sana / vaqt (ilova temasiga moslangan tanlagichlar) ───────────────────

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _deadlineDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _deadlineDate = picked;
        // Muddat belgilanganda vaqt avtomatik kun oxiriga (23:59) o'tadi.
        _deadlineTime = const TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  Future<void> _pickTime(bool deadline) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (deadline ? _deadlineTime : _estimated) ??
          const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) {
      setState(() => deadline ? _deadlineTime = picked : _estimated = picked);
    }
  }

  Future<void> _pickFiles() async {
    // Tanlagich turli platforma xatolarini (jumladan MissingPluginException —
    // plugin ro'yxatdan o'tmagan bo'lsa) otishi mumkin; ilovani yiqitmaymiz.
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result == null) return;
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _files.add(f);
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

  // ── Tahrirlash: detal kelganda maydonlarni to'ldirish ─────────────────────

  /// Detal maydonlarini forma holatiga bir marta ko'chiradi.
  void _applyDetail(TaskDetail d) {
    _prefilled = true;
    _nameCtrl.text = d.title;
    _descCtrl.text = d.description;
    _priceCtrl.text = Formatters.formatAmount(_intPart(d.taskPrice));
    _penaltyCtrl.text = _intPart(d.penaltyPercentage);
    _sprintCtrl.text = d.sprint?.toString() ?? '';
    _priority = d.priority == TaskPriority.unknown ? null : d.priority;
    _type = d.type;
    _projectFallbackTitle = d.projectInfo.isEmpty ? null : d.projectInfo;
    final deadline = d.deadline;
    _originalDeadline = deadline;
    if (deadline != null) {
      _deadlineDate = deadline;
      _deadlineTime = TimeOfDay.fromDateTime(deadline);
    }
    final est = d.estimatedMinutes ?? 0;
    if (est > 0) {
      // ponytail: TimeOfDay 23:59 dan oshaolmaydi — kattaroq qiymat qisqaradi.
      _estimated = TimeOfDay(hour: (est ~/ 60).clamp(0, 23), minute: est % 60);
    }
    final assigneeId = d.assigneeId;
    if (assigneeId != null) {
      _assigner = ProjectMember(
        id: assigneeId,
        username: d.assigneeName,
        position: d.assigneePosition,
      );
    }
    final positionId = d.positionId;
    if (positionId != null) {
      _position = Position(id: positionId, name: d.positionName);
    }
  }

  /// Tanlanmagan loyihani detal (`project` id yoki `project_info` nomi)
  /// bo'yicha `project-shorts` ro'yxatidan topadi — topilsa Topshiruvchi
  /// ro'yxati ham yuklanadi.
  void _syncProjectFromDetail(TaskCreateState state) {
    final d = state.detail;
    if (_project != null || d == null) return;
    for (final p in state.projects) {
      if (p.id == d.projectId ||
          (d.projectId == null && p.title == d.projectInfo)) {
        _project = p;
        context.read<TaskCreateBloc>().add(TaskCreateProjectSelected(p.id));
        return;
      }
    }
  }

  // ── Yuborish ──────────────────────────────────────────────────────────────

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final scope = _editScope(context.read<TaskCreateBloc>().state);
    if (_isEdit && scope == TaskEditScope.none) {
      AppToast.showError(context, title: l10n.commonError);
      return;
    }
    // Tahrirlashda loyiha allaqachon mavjud (id topilmasa PATCH'da yuborilmaydi).
    if ((scope != TaskEditScope.deadlineOnly &&
            ((_project == null && !_isEdit) ||
                _nameCtrl.text.trim().isEmpty)) ||
        _deadlineDate == null) {
      AppToast.showError(context, title: l10n.taskCreateRequiredError);
      return;
    }

    final date = _deadlineDate!;
    final time = _deadlineTime ?? const TimeOfDay(hour: 23, minute: 59);
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scope == TaskEditScope.deadlineOnly &&
        _originalDeadline != null &&
        _sameMinute(deadline, _originalDeadline!)) {
      AppToast.showError(context, title: l10n.taskDeadlineChangeRequired);
      return;
    }

    final price = _digits(_priceCtrl.text);
    final penalty = _digits(_penaltyCtrl.text);
    final estimated = _estimated == null
        ? null
        : _estimated!.hour * 60 + _estimated!.minute;

    final task = NewTask(
      project: _project?.id,
      title: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      deadline: deadline,
      priority: _priorityApi(_priority),
      type: _type?.apiValue,
      assignee: _assigner?.id,
      position: (_position != null && _position!.id > 0) ? _position!.id : null,
      taskPrice: price.isEmpty ? null : price,
      penaltyPercentage: penalty.isEmpty ? null : penalty,
      sprint: int.tryParse(_sprintCtrl.text),
      estimatedMinutes: estimated,
      deadlineOnly: scope == TaskEditScope.deadlineOnly,
    );
    final filePaths = [for (final f in _files) f.path!];

    final taskId = widget.taskId;
    context.read<TaskCreateBloc>().add(
      taskId == null
          ? TaskCreateSubmitted(
              SubmitTaskParams(task: task, filePaths: filePaths),
            )
          : TaskCreateUpdateSubmitted(
              UpdateTaskParams(
                id: taskId,
                task: task,
                removedAttachmentIds: List.of(_removedAttachmentIds),
                filePaths: filePaths,
              ),
            ),
    );
  }

  bool _sameMinute(DateTime left, DateTime right) =>
      left.year == right.year &&
      left.month == right.month &&
      left.day == right.day &&
      left.hour == right.hour &&
      left.minute == right.minute;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<TaskCreateBloc, TaskCreateState>(
          listenWhen: (p, c) => p.submitStatus != c.submitStatus,
          listener: (context, state) {
            switch (state.submitStatus) {
              case TaskSubmitStatus.success:
                AppToast.showSuccess(
                  context,
                  title: _isEdit
                      ? l10n.taskUpdateSuccess
                      : l10n.taskCreateSuccess,
                );
                // `true` — ro'yxat sahifasi qaytganda o'zini yangilashi uchun.
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
        ),
        // Tahrirlash: detal kelganda bir marta prefill; loyihalar ro'yxati
        // keyin kelsa ham loyihani moslashtirishga qayta urinamiz.
        BlocListener<TaskCreateBloc, TaskCreateState>(
          listenWhen: (p, c) =>
              p.detail != c.detail || p.projects != c.projects,
          listener: (context, state) {
            final detail = state.detail;
            if (detail == null) return;
            setState(() {
              if (!_prefilled) _applyDetail(detail);
              _syncProjectFromDetail(state);
            });
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: OverlayPortal(
            controller: _portalCtrl,
            overlayChildBuilder: _buildOverlay,
            child: Column(
              children: [
                _Header(
                  title: _isEdit ? l10n.taskEditTitle : l10n.taskCreateTitle,
                ),
                Expanded(child: _buildFormArea(l10n)),
                _buildSubmitBar(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Forma maydoni: tahrirlashda detal yuklanmaguncha spinner, yuklanmasa
  /// xato + qayta urinish (bo'sh forma bilan PATCH yubormaslik uchun).
  Widget _buildFormArea(AppLocalizations l10n) {
    if (!_isEdit) return _buildForm(l10n, const [], TaskEditScope.full);
    return BlocBuilder<TaskCreateBloc, TaskCreateState>(
      buildWhen: (p, c) =>
          p.detail != c.detail ||
          p.detailLoading != c.detailLoading ||
          p.attachments != c.attachments ||
          p.permissionContext != c.permissionContext,
      builder: (context, state) {
        if (state.detail == null) {
          if (state.detailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _DetailErrorState(
            onRetry: () => context.read<TaskCreateBloc>().add(
              TaskCreateDetailRequested(widget.taskId!),
            ),
          );
        }
        final scope = _editScope(state);
        if (scope == TaskEditScope.none) {
          return _DetailErrorState(
            onRetry: () => Navigator.of(context).maybePop(),
          );
        }
        return _buildForm(l10n, state.attachments, scope);
      },
    );
  }

  /// Pastki tugma: yaratishda "Vazifa qo'shish", tahrirlashda "Saqlash"
  /// (detal yuklanmaguncha ko'rinmaydi).
  Widget _buildSubmitBar(AppLocalizations l10n) {
    return BlocBuilder<TaskCreateBloc, TaskCreateState>(
      buildWhen: (p, c) =>
          p.submitStatus != c.submitStatus || p.detail != c.detail,
      builder: (context, state) {
        if (_isEdit && state.detail == null) return const SizedBox.shrink();
        final scope = _editScope(state);
        if (scope == TaskEditScope.none) return const SizedBox.shrink();
        return _SubmitBar(
          label: _isEdit ? l10n.taskEditSave : l10n.taskCreateTitle,
          loading: state.submitStatus == TaskSubmitStatus.submitting,
          onTap: _submit,
        );
      },
    );
  }

  Widget _buildForm(
    AppLocalizations l10n,
    List<TaskAttachmentInfo> attachments,
    TaskEditScope scope,
  ) {
    if (scope == TaskEditScope.deadlineOnly) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: Row(
          children: [
            Expanded(
              child: _SelectField(
                label: l10n.taskCreateFieldDeadline,
                value: _fmtDate(_deadlineDate),
                placeholder: l10n.taskCreateFieldDeadline,
                icon: Assets.icons.icCalendar,
                onTap: _pickDate,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _SelectField(
                label: l10n.taskCreateFieldTime,
                value: _fmtTime(_deadlineTime),
                placeholder: '00:00',
                icon: Assets.icons.icTuilconTime,
                onTap: () => _pickTime(true),
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          _SelectField(
            label: l10n.taskCreateFieldProject,
            value: _project?.title ?? _projectFallbackTitle,
            placeholder: l10n.taskCreateProjectHint,
            link: _links[_Field.project],
            onTap: () => _toggle(_Field.project),
          ),
          _InputField(
            label: l10n.taskCreateFieldName,
            hint: l10n.taskCreateNameHint,
            controller: _nameCtrl,
          ),
          _TextAreaField(
            label: l10n.taskCreateFieldDescription,
            hint: l10n.taskCreateDescriptionHint,
            controller: _descCtrl,
          ),
          _SelectField(
            label: l10n.taskCreateFieldPriority,
            value: _priority == null ? null : _priorityLabel(_priority!, l10n),
            placeholder: l10n.taskCreatePriorityHint,
            link: _links[_Field.priority],
            onTap: () => _toggle(_Field.priority),
          ),
          _SelectField(
            label: l10n.taskCreateFieldType,
            value: _type == null ? null : _typeLabel(_type!, l10n),
            placeholder: l10n.taskCreateTypeHint,
            link: _links[_Field.type],
            onTap: () => _toggle(_Field.type),
          ),
          _SelectField(
            label: l10n.taskCreateFieldAssigner,
            value: _assigner?.username,
            placeholder: l10n.taskCreateFieldAssigner,
            link: _links[_Field.assigner],
            onTap: _onAssignerTap,
          ),
          _SelectField(
            label: l10n.taskCreateFieldPositions,
            value: _position?.name,
            placeholder: l10n.taskCreatePositionsHint,
            link: _links[_Field.positions],
            onTap: () => _toggle(_Field.positions),
          ),
          _InputField(
            label: l10n.taskCreateFieldSprint,
            hint: '0',
            controller: _sprintCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _InputField(
            label: l10n.taskCreateFieldPrice,
            hint: l10n.taskCreatePriceHint,
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            inputFormatters: [_ThousandsFormatter()],
          ),
          _InputField(
            label: l10n.taskCreateFieldPenalty,
            hint: l10n.taskCreatePenaltyHint,
            controller: _penaltyCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [_MaxValueFormatter(100)],
          ),
          Row(
            children: [
              Expanded(
                child: _SelectField(
                  label: l10n.taskCreateFieldDeadline,
                  value: _fmtDate(_deadlineDate),
                  placeholder: l10n.taskCreateFieldDeadline,
                  icon: Assets.icons.icCalendar,
                  onTap: _pickDate,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _SelectField(
                  label: l10n.taskCreateFieldTime,
                  value: _fmtTime(_deadlineTime),
                  placeholder: '00:00',
                  icon: Assets.icons.icTuilconTime,
                  onTap: () => _pickTime(true),
                ),
              ),
            ],
          ),
          _SelectField(
            label: l10n.taskCreateFieldEstimated,
            value: _fmtTime(_estimated),
            placeholder: '00:00',
            icon: Assets.icons.icTuilconTime,
            onTap: () => _pickTime(false),
          ),
          _FilesRow(
            label: l10n.taskCreateFieldFiles,
            files: _files,
            existing: [
              for (final a in attachments)
                if (!_removedAttachmentIds.contains(a.id)) a,
            ],
            onPick: _pickFiles,
            onRemove: (f) => setState(() => _files.remove(f)),
            onRemoveExisting: (a) =>
                setState(() => _removedAttachmentIds.add(a.id)),
          ),
        ],
      ),
    );
  }

  // ── Overlay dropdown ──────────────────────────────────────────────────────

  Widget _buildOverlay(BuildContext context) {
    final link = _links[_open];
    if (link == null) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width - 40.w;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(width: width, child: _dropdownContent()),
        ),
      ],
    );
  }

  Widget _dropdownContent() {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<TaskCreateBloc, TaskCreateState>(
      builder: (context, state) {
        switch (_open) {
          case _Field.project:
            return _DropdownBox(
              children: [
                for (final p in state.projects)
                  _DropdownItem(
                    selected: p == _project,
                    onTap: () => _selectProject(p),
                    child: _ProjectRowContent(project: p),
                  ),
              ],
            );
          case _Field.priority:
            return _DropdownBox(
              children: [
                for (final p in _priorities)
                  _DropdownItem(
                    selected: p == _priority,
                    onTap: () => _pick(() => _priority = p),
                    child: _labelRow(_priorityLabel(p, l10n)),
                  ),
              ],
            );
          case _Field.type:
            return _DropdownBox(
              children: [
                for (final t in _types)
                  _DropdownItem(
                    selected: t == _type,
                    onTap: () => _pick(() => _type = t),
                    child: _labelRow(_typeLabel(t, l10n)),
                  ),
              ],
            );
          case _Field.assigner:
            if (state.membersLoading) {
              return _DropdownBox(children: const [_DropdownLoader()]);
            }
            return _DropdownBox(
              children: [
                for (final m in state.members)
                  _DropdownItem(
                    selected: m == _assigner,
                    onTap: () => _selectAssigner(m),
                    child: _MemberRowContent(member: m),
                  ),
              ],
            );
          case _Field.positions:
            return _DropdownBox(
              children: [
                for (final pos in state.positions)
                  _DropdownItem(
                    selected: pos == _position,
                    onTap: () => _pick(() => _position = pos),
                    child: _labelRow(pos.name),
                  ),
              ],
            );
          case _Field.none:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _labelRow(String text) => text
      .s(13.sp)
      .w(700)
      .c(AppColors.of(context).textStrong)
      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);

  /// Sana/vaqt tanlagichini ilova ranglariga (accent + yumaloq + surface) moslaydi.
  Widget _themedPicker(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    final isDark = colors.backgroundBase.computeLuminance() < 0.5;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    );

    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: colors.accentSub,
          onPrimary: colors.textWhite,
          surface: colors.backgroundBase,
          onSurface: colors.textStrong,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: colors.backgroundBase,
          headerBackgroundColor: colors.accentStrong,
          headerForegroundColor: colors.textWhite,
          shape: shape,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: colors.backgroundBase,
          shape: shape,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colors.accentSub),
        ),
      ),
      child: child,
    );
  }
}

// ── Enum → localizatsiya / API ─────────────────────────────────────────────

String _priorityLabel(TaskPriority p, AppLocalizations l10n) => switch (p) {
  TaskPriority.low => l10n.taskPriorityLow,
  TaskPriority.medium => l10n.taskPriorityMedium,
  TaskPriority.high => l10n.taskPriorityHigh,
  TaskPriority.critical => l10n.taskPriorityCritical,
  TaskPriority.unknown => '',
};

String? _priorityApi(TaskPriority? p) => switch (p) {
  TaskPriority.low => 'low',
  TaskPriority.medium => 'medium',
  TaskPriority.high => 'high',
  TaskPriority.critical => 'critical',
  _ => null,
};

/// Domen [TaskType] (schema `Type225Enum`: bug/extra/feature/research) uchun
/// yorliqlar — `extra` dizayndagi "Qo'shimcha" bandiga to'g'ri keladi.
String _typeLabel(TaskType t, AppLocalizations l10n) => switch (t) {
  TaskType.bug => l10n.taskTypeBug,
  TaskType.feature => l10n.taskTypeFeature,
  TaskType.extra => l10n.taskTypeAddition,
  TaskType.research => l10n.taskTypeResearch,
};

String _digits(String s) => s.replaceAll(RegExp('[^0-9]'), '');

/// Decimal string'ning butun qismi ("150000.00" → "150000").
String _intPart(String s) => _digits(s.split('.').first);

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

String _fmtTime(TimeOfDay? t) {
  if (t == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}

// ── Kiritish formatlagichlari ─────────────────────────────────────────────────

/// Raqamni 3 xonadan bo'lib guruhlaydi ("1 000 000") — kiritilayotgan payt.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = Formatters.formatAmount(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Raqamni [max] bilan cheklaydi (oshib ketsa avtomatik [max] bo'ladi).
class _MaxValueFormatter extends TextInputFormatter {
  _MaxValueFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    var value = int.parse(digits);
    if (value > max) value = max;
    final text = value.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Sarlavha ─────────────────────────────────────────────────────────────────

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
          SizedBox(width: 24.w),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Assets.icons.icClose.svg(
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Umumiy maydon qismlari ────────────────────────────────────────────────────

/// 11sp bold ustki yorliq (textSub).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 4.h),
      child: text.s(11.sp).w(700).c(AppColors.of(context).textSub),
    );
  }
}

/// Chegara + fon (background-base, stroke-sub, 12 radius).
BoxDecoration _fieldBoxDecoration(AppColors colors) => BoxDecoration(
  color: colors.backgroundBase,
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: colors.strokeSub, width: 1.w),
);

/// Bosilganda ostidan dropdown ochadigan tanlov maydoni.
class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.label,
    required this.value,
    required this.placeholder,
    this.onTap,
    this.icon,
    this.link,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  final SvgGenImage? icon;
  final LayerLink? link;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    Widget box = DecoratedBox(
      decoration: _fieldBoxDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              Expanded(
                child: (hasValue ? value! : placeholder)
                    .s(13.sp)
                    .w(700)
                    .c(hasValue ? colors.textStrong : colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 4.w),
              (icon ?? Assets.icons.icTuilconChervonDown).svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
    if (link != null) {
      box = CompositedTransformTarget(link: link!, child: box);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: box,
        ),
      ],
    );
  }
}

/// Bir qatorli matn/raqam maydoni.
class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.textAlign = TextAlign.left,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: colors.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label),
        DecoratedBox(
          decoration: _fieldBoxDecoration(colors),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: SizedBox(
              height: 44.h,
              child: Center(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textAlign: textAlign,
                  inputFormatters: inputFormatters,
                  style: style,
                  cursorColor: colors.accentSub,
                  decoration: InputDecoration.collapsed(
                    hintText: hint,
                    hintStyle: style.copyWith(color: colors.textSub),
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

/// Ko'p qatorli tavsif maydoni — fokusda accent chegara, matn bo'lsa tozalash
/// (×) tugmasi yuqori-o'ngda ko'rinadi.
class _TextAreaField extends StatefulWidget {
  const _TextAreaField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  State<_TextAreaField> createState() => _TextAreaFieldState();
}

class _TextAreaFieldState extends State<_TextAreaField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focus.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasText = widget.controller.text.isNotEmpty;
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: colors.textStrong,
      height: 20 / 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(widget.label),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundBase,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _focus.hasFocus ? colors.strokeAccent : colors.strokeSub,
              width: _focus.hasFocus ? 1.5.w : 1.w,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14.w,
                  9.h,
                  hasText ? 34.w : 14.w,
                  9.h,
                ),
                child: SizedBox(
                  height: 60.h,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.multiline,
                    style: style,
                    cursorColor: colors.accentSub,
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: style.copyWith(color: colors.textSub),
                    ),
                  ),
                ),
              ),
              if (hasText)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: InkWell(
                    onTap: widget.controller.clear,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Assets.icons.icClose.svg(
                        width: 16.w,
                        height: 16.w,
                        colorFilter: ColorFilter.mode(
                          colors.iconSub,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dropdown quti + qatorlar ──────────────────────────────────────────────────

/// Overlay dropdown qutisi (background-base, stroke-sub, 12 radius, 6 padding).
class _DropdownBox extends StatelessWidget {
  const _DropdownBox({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: children.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: l10n.statEmpty.s(13.sp).w(500).c(colors.textSub),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2.h,
                      children: children,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Bitta tanlanadigan dropdown qatori (tanlangan → elevation-1-alt fon).
class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.backgroundElevation1Alt : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: Align(alignment: Alignment.centerLeft, child: child),
        ),
      ),
    );
  }
}

/// Loyiha qatori: sarlavha + tavsif (chapda), muddat (o'ngda).
class _ProjectRowContent extends StatelessWidget {
  const _ProjectRowContent({required this.project});

  final ProjectShort project;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              project.title
                  .s(13.sp)
                  .w(700)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (project.description.isNotEmpty) ...[
                SizedBox(height: 2.h),
                project.description
                    .s(11.sp)
                    .w(700)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
        if (project.deadline != null) ...[
          SizedBox(width: 12.w),
          _fmtDate(project.deadline).s(11.sp).w(700).c(colors.iconSub),
        ],
      ],
    );
  }
}

/// Topshiruvchi qatori: avatar + ism (bold) + lavozim (sub).
class _MemberRowContent extends StatelessWidget {
  const _MemberRowContent({required this.member});

  final ProjectMember member;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        TuiAvatar(initial: member.username, avatarUrl: member.avatar, size: 32),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              member.username
                  .s(13.sp)
                  .w(700)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (member.position.isNotEmpty) ...[
                SizedBox(height: 2.h),
                member.position
                    .s(11.sp)
                    .w(500)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownLoader extends StatelessWidget {
  const _DropdownLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: AppColors.of(context).accentSub,
          ),
        ),
      ),
    );
  }
}

// ── "Qo'shimcha fayllar" ──────────────────────────────────────────────────────

class _FilesRow extends StatelessWidget {
  const _FilesRow({
    required this.label,
    required this.files,
    required this.onPick,
    required this.onRemove,
    this.existing = const [],
    this.onRemoveExisting,
  });

  final String label;
  final List<PlatformFile> files;
  final VoidCallback onPick;
  final ValueChanged<PlatformFile> onRemove;

  /// Vazifaga allaqachon biriktirilgan fayllar (tahrirlash rejimi).
  final List<TaskAttachmentInfo> existing;
  final ValueChanged<TaskAttachmentInfo>? onRemoveExisting;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(20.r),
                child: _DashedBox(
                  color: colors.strokeAccent,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.icDocument.svg(
                        width: 16.w,
                        height: 16.w,
                        colorFilter: ColorFilter.mode(
                          colors.textSoft,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      l10n.taskCreateFileUpload
                          .s(11.sp)
                          .w(700)
                          .c(colors.textSoft),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(20.r),
                child: _DashedBox(
                  color: colors.strokeStrong,
                  child: Assets.icons.icPlus.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (existing.isNotEmpty || files.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final a in existing)
                _FileChip(
                  name: a.name,
                  url: a.fileUrl,
                  onRemove: () => onRemoveExisting?.call(a),
                ),
              for (final f in files)
                _FileChip(name: f.name, onRemove: () => onRemove(f)),
            ],
          ),
        ],
      ],
    );
  }
}

/// Fayl chipi (nom + olib tashlash) — yangi tanlangan ham, mavjud biriktirilgan
/// ham shu ko'rinishda.
class _FileChip extends StatelessWidget {
  const _FileChip({required this.name, required this.onRemove, this.url = ''});

  final String name;
  final VoidCallback onRemove;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 132.w),
              child: name
                  .s(11.sp)
                  .w(700)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (url.isNotEmpty) ...[
              SizedBox(width: 4.w),
              AppFileActions(
                url: url,
                openLabel: AppLocalizations.of(context).commonOpenFile,
                downloadLabel: AppLocalizations.of(context).commonDownloadFile,
                errorTitle: AppLocalizations.of(context).commonError,
              ),
            ],
            SizedBox(width: 2.w),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8.r),
              child: Assets.icons.icClose.svg(
                width: 14.w,
                height: 14.w,
                colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tahrirlash detali yuklanmaganda ko'rsatiladigan xato + qayta urinish.
class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.onRetry});

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

class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: 20.r),
      child: SizedBox(
        height: 56.h,
        child: Center(child: child),
      ),
    );
  }
}

/// Chiziqli (dashed) yumaloq to'rtburchak chegara chizuvchi.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

// ── Pastki "Vazifa qo'shish" tugmasi ──────────────────────────────────────────

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.label,
    required this.onTap,
    this.loading = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.accentStrong,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              height: 52.h,
              child: Center(
                child: loading
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          color: colors.textWhite,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.icons.icTuilconCheck.svg(
                            width: 16.w,
                            height: 16.w,
                            colorFilter: ColorFilter.mode(
                              colors.textWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          label.s(15.sp).w(800).c(colors.textWhite),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
