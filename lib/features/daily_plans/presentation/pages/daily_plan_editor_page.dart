import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../bloc/daily_plans_bloc.dart';

class DailyPlanEditorPage extends StatelessWidget {
  const DailyPlanEditorPage({this.initial, super.key});

  final DailyPlan? initial;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DailyPlansBloc>(),
    child: _DailyPlanEditorView(initial: initial),
  );
}

class _DailyPlanEditorView extends StatefulWidget {
  const _DailyPlanEditorView({this.initial});

  final DailyPlan? initial;

  @override
  State<_DailyPlanEditorView> createState() => _DailyPlanEditorViewState();
}

class _DailyPlanEditorViewState extends State<_DailyPlanEditorView> {
  late final TextEditingController _titleController;
  late final List<TextEditingController> _itemControllers;
  late DailyPlanColor _color;
  DateTime _deadline = DateTime.now();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleController = TextEditingController(text: initial?.title ?? '');
    _color = initial?.color ?? DailyPlanColor.yellow;
    _itemControllers = [
      ...?initial?.items.map((item) => TextEditingController(text: item.title)),
    ];
    while (_itemControllers.length < 5) {
      _itemControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null && mounted) setState(() => _deadline = selected);
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _submitting = true);
    final initialItems = widget.initial?.items ?? const <DailyPlanItem>[];
    context.read<DailyPlansBloc>().add(
      DailyPlanFormSaved(
        id: widget.initial?.id,
        input: DailyPlanInput(title: title, color: _color),
        items: [
          for (var index = 0; index < _itemControllers.length; index++)
            if (_itemControllers[index].text.trim().isNotEmpty ||
                index < initialItems.length)
              (
                item: index < initialItems.length ? initialItems[index] : null,
                title: _itemControllers[index].text.trim().isEmpty
                    ? initialItems[index].title
                    : _itemControllers[index].text.trim(),
              ),
        ],
      ),
    );
  }

  void _addItemField() {
    setState(() => _itemControllers.add(TextEditingController()));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.initial != null;
    return BlocListener<DailyPlansBloc, DailyPlansState>(
      listenWhen: (previous, current) => previous.message != current.message,
      listener: (context, state) {
        switch (state.message) {
          case DailyPlansMessage.planSaved:
            AppToast.showSuccess(context, title: l10n.dailyPlansSaved);
            context.pop(true);
          case DailyPlansMessage.failure:
            setState(() => _submitting = false);
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.failure?.message,
            );
          case DailyPlansMessage.planDeleted:
          case null:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: Column(
            children: [
              _EditorHeader(
                title: isEditing ? l10n.dailyPlansEditTask : l10n.dailyPlansAdd,
                color: _color,
                onColorChanged: (color) => setState(() => _color = color),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 600.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PlanInputCard(
                            titleController: _titleController,
                            itemControllers: _itemControllers,
                            onAddItem: _addItemField,
                          ),
                          SizedBox(height: 20.h),
                          _DeadlineField(
                            value: _deadline,
                            onTap: _selectDeadline,
                            onToday: () =>
                                setState(() => _deadline = DateTime.now()),
                            onTomorrow: () => setState(
                              () => _deadline = DateTime.now().add(
                                const Duration(days: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accentStrong,
                        disabledBackgroundColor: colors.accentDisabled,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: _submitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: colors.iconWhite,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.icPlus.svg(
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.iconWhite,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                (isEditing
                                        ? l10n.dailyPlansSave
                                        : l10n.dailyPlansAdd)
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
        ),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.color,
    required this.onColorChanged,
  });

  final String title;
  final DailyPlanColor color;
  final ValueChanged<DailyPlanColor> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          InkWell(
            onTap: context.pop,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 16.w,
                height: 16.w,
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
          PopupMenuButton<DailyPlanColor>(
            tooltip: '',
            onSelected: onColorChanged,
            color: colors.backgroundElevation1,
            elevation: 0,
            padding: EdgeInsets.zero,
            offset: Offset(0, 36.h),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: colors.strokeSub, width: 1.w),
              borderRadius: BorderRadius.circular(8.r),
            ),
            itemBuilder: (_) => [
              for (final option in DailyPlanColor.values)
                PopupMenuItem(
                  value: option,
                  height: 28.h,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _colorFor(colors, option),
                      shape: BoxShape.circle,
                      border: option == color
                          ? Border.all(color: colors.strokeStrong, width: 1.w)
                          : null,
                    ),
                    child: SizedBox(width: 24.w, height: 24.w),
                  ),
                ),
            ],
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _colorFor(colors, color),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Assets.icons.icDailyPlanStar.svg(
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanInputCard extends StatelessWidget {
  const _PlanInputCard({
    required this.titleController,
    required this.itemControllers,
    required this.onAddItem,
  });

  final TextEditingController titleController;
  final List<TextEditingController> itemControllers;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final cursorColor = _inputCursorColor(colors);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        border: Border.all(color: colors.strokeSub, width: 1.w),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              cursorColor: cursorColor,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: colors.textStrong,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).dailyPlansTaskName,
                hintStyle: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: colors.textSoft,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
            SizedBox(height: 12.h),
            for (var index = 0; index < itemControllers.length; index++)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: _inputSurfaceColor(colors),
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 21.w, height: 21.w),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: itemControllers[index],
                        cursorColor: cursorColor,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: colors.textStrong,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            InkWell(
              onTap: onAddItem,
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.icPlus.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconAccent,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    AppLocalizations.of(
                      context,
                    ).dailyPlansItemHint.s(13.sp).w(600).c(colors.textAccent),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineField extends StatelessWidget {
  const _DeadlineField({
    required this.value,
    required this.onTap,
    required this.onToday,
    required this.onTomorrow,
  });

  final DateTime value;
  final VoidCallback onTap;
  final VoidCallback onToday;
  final VoidCallback onTomorrow;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        l10n.dailyPlansDeadline.s(11.sp).w(500).c(colors.textSub),
        SizedBox(height: 4.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: colors.strokeSub, width: 1.w),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SizedBox(
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: DateFormat(
                        'dd.MM.yyyy',
                      ).format(value).s(13.sp).w(500).c(colors.textStrong),
                    ),
                    Assets.icons.icCalendar.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _DeadlineShortcut(
                label: l10n.dailyPlansToday,
                selected: DateUtils.isSameDay(value, DateTime.now()),
                onTap: onToday,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _DeadlineShortcut(
                label: l10n.dailyPlansTomorrow,
                selected: DateUtils.isSameDay(
                  value,
                  DateTime.now().add(const Duration(days: 1)),
                ),
                onTap: onTomorrow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeadlineShortcut extends StatelessWidget {
  const _DeadlineShortcut({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _inputSurfaceColor(colors),
          border: selected
              ? Border.all(color: colors.strokeAccent, width: 1.w)
              : null,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
          height: 36.h,
          child: Center(child: label.s(13.sp).w(500).c(colors.textStrong)),
        ),
      ),
    );
  }
}

Color _colorFor(AppColors colors, DailyPlanColor color) => switch (color) {
  DailyPlanColor.red => colors.dailyPlanRed,
  DailyPlanColor.yellow => colors.dailyPlanYellow,
  DailyPlanColor.green => colors.dailyPlanGreen,
  DailyPlanColor.blue => colors.dailyPlanBlue,
};

bool _isDark(AppColors colors) => colors.backgroundBase.computeLuminance() < .5;

Color _inputSurfaceColor(AppColors colors) => _isDark(colors)
    ? colors.backgroundElevation1Alt
    : colors.backgroundElevation2;

Color _inputCursorColor(AppColors colors) =>
    _isDark(colors) ? colors.iconWhite : colors.iconStrong;
