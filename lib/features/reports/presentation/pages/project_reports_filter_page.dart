import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/project_report_filter.dart';
import '../bloc/project_reports_filter_bloc.dart';

/// Loyiha bo'yicha hisobotni filtrlash sahifasi (`Routes.projectReportsFilter`).
/// "Shakllantirish" bosilganda tuzilgan [ProjectReportFilter] `pop` orqali
/// qaytariladi; qidiruv matni ([ProjectReportFilter.search]) saqlanadi.
/// Dropdown yo'q — bu yerdagi barcha maydonlar sana/summa oralig'i yoki
/// alohida sahifadagi ko'p-tanlov (Muallifi/Boshqaruvchi/Xodimlar/Sinovchilar).
class ProjectReportsFilterPage extends StatelessWidget {
  const ProjectReportsFilterPage({required this.initial, super.key});

  final ProjectReportFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectReportsFilterBloc>(
      create: (_) =>
          getIt<ProjectReportsFilterBloc>()
            ..add(const ProjectReportsFilterOptionsRequested()),
      child: _ProjectReportsFilterView(initial: initial),
    );
  }
}

class _ProjectReportsFilterView extends StatefulWidget {
  const _ProjectReportsFilterView({required this.initial});

  final ProjectReportFilter initial;

  @override
  State<_ProjectReportsFilterView> createState() =>
      _ProjectReportsFilterViewState();
}

class _ProjectReportsFilterViewState extends State<_ProjectReportsFilterView> {
  final Set<int> _authorIds = {};
  final Set<int> _managerIds = {};
  final Set<int> _employeeIds = {};
  final Set<int> _testerIds = {};

  DateTime? _deadlineFromDate;
  TimeOfDay? _deadlineFromTime;
  DateTime? _deadlineToDate;
  TimeOfDay? _deadlineToTime;

  late final _priceFromCtrl = TextEditingController();
  late final _priceToCtrl = TextEditingController();

  late String _search;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _authorIds.addAll(f.authorIds);
    _managerIds.addAll(f.managerIds);
    _employeeIds.addAll(f.employeeIds);
    _testerIds.addAll(f.testerIds);
    if (f.deadlineFrom != null) {
      _deadlineFromDate = f.deadlineFrom;
      _deadlineFromTime = TimeOfDay.fromDateTime(f.deadlineFrom!);
    }
    if (f.deadlineTo != null) {
      _deadlineToDate = f.deadlineTo;
      _deadlineToTime = TimeOfDay.fromDateTime(f.deadlineTo!);
    }
    _priceFromCtrl.text = _numText(f.priceFrom);
    _priceToCtrl.text = _numText(f.priceTo);
    _search = f.search;
  }

  @override
  void dispose() {
    _priceFromCtrl.dispose();
    _priceToCtrl.dispose();
    super.dispose();
  }

  static String _numText(num? value) => value == null ? '' : '$value';

  num? _parseNum(String text) => num.tryParse(text.trim());

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final initial = (from ? _deadlineFromDate : _deadlineToDate) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(
        () => from ? _deadlineFromDate = picked : _deadlineToDate = picked,
      );
    }
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (from ? _deadlineFromTime : _deadlineToTime) ??
          const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) {
      setState(
        () => from ? _deadlineFromTime = picked : _deadlineToTime = picked,
      );
    }
  }

  Future<void> _openSelect({
    required String title,
    required Set<int> current,
  }) async {
    final state = context.read<ProjectReportsFilterBloc>().state;
    final items = [
      for (final u in state.users)
        MultiSelectItem(
          id: u.id,
          initial: u.username,
          title: u.username,
          subtitle: u.position,
          avatarUrl: u.avatar,
        ),
    ];
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(title: title, items: items, selected: current),
    );
    if (result is Set<int>) {
      setState(() {
        current
          ..clear()
          ..addAll(result);
      });
    }
  }

  String? _summary(Set<int> ids, AppLocalizations l10n) =>
      ids.isEmpty ? null : l10n.taskFilterSelectedCount(ids.length);

  void _reset() {
    setState(() {
      _authorIds.clear();
      _managerIds.clear();
      _employeeIds.clear();
      _testerIds.clear();
      _deadlineFromDate = null;
      _deadlineFromTime = null;
      _deadlineToDate = null;
      _deadlineToTime = null;
      _priceFromCtrl.clear();
      _priceToCtrl.clear();
    });
  }

  void _apply() {
    DateTime? combine(DateTime? d, TimeOfDay? t) => d == null
        ? null
        : DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);

    Navigator.of(context).pop(
      ProjectReportFilter(
        deadlineFrom: combine(_deadlineFromDate, _deadlineFromTime),
        deadlineTo: combine(_deadlineToDate, _deadlineToTime),
        priceFrom: _parseNum(_priceFromCtrl.text),
        priceTo: _parseNum(_priceToCtrl.text),
        authorIds: {..._authorIds},
        managerIds: {..._managerIds},
        employeeIds: {..._employeeIds},
        testerIds: {..._testerIds},
        search: _search,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            AppFilterHeader(title: l10n.taskFilterTitle),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12.h,
                  children: [
                    _DateRange(
                      label: l10n.reportFilterDateRange,
                      fromDate: _fmtDate(_deadlineFromDate),
                      fromTime: _fmtTime(_deadlineFromTime),
                      toDate: _fmtDate(_deadlineToDate),
                      toTime: _fmtTime(_deadlineToTime),
                      onFromDate: () => _pickDate(true),
                      onFromTime: () => _pickTime(true),
                      onToDate: () => _pickDate(false),
                      onToTime: () => _pickTime(false),
                    ),
                    _AmountRange(
                      label: l10n.reportFilterManagerBonus,
                      fromCtrl: _priceFromCtrl,
                      toCtrl: _priceToCtrl,
                    ),
                    AppFilterFieldBox(
                      label: l10n.reportFilterAuthor,
                      value: _summary(_authorIds, l10n),
                      placeholder: l10n.reportFilterAuthorHint,
                      chevron: Assets.icons.icUserGroup,
                      onTap: () => _openSelect(
                        title: l10n.reportFilterAuthorHint,
                        current: _authorIds,
                      ),
                      onClear: () => setState(_authorIds.clear),
                    ),
                    AppFilterFieldBox(
                      label: l10n.reportFilterManager,
                      value: _summary(_managerIds, l10n),
                      placeholder: l10n.reportFilterManagerHint,
                      chevron: Assets.icons.icUserGroup,
                      onTap: () => _openSelect(
                        title: l10n.reportFilterManagerHint,
                        current: _managerIds,
                      ),
                      onClear: () => setState(_managerIds.clear),
                    ),
                    AppFilterFieldBox(
                      label: l10n.reportFilterEmployees,
                      value: _summary(_employeeIds, l10n),
                      placeholder: l10n.reportFilterEmployeesHint,
                      chevron: Assets.icons.icUserGroup,
                      onTap: () => _openSelect(
                        title: l10n.reportFilterEmployeesHint,
                        current: _employeeIds,
                      ),
                      onClear: () => setState(_employeeIds.clear),
                    ),
                    AppFilterFieldBox(
                      label: l10n.reportFilterTesters,
                      value: _summary(_testerIds, l10n),
                      placeholder: l10n.reportFilterTestersHint,
                      chevron: Assets.icons.icUserGroup,
                      onTap: () => _openSelect(
                        title: l10n.reportFilterTestersHint,
                        current: _testerIds,
                      ),
                      onClear: () => setState(_testerIds.clear),
                    ),
                  ],
                ),
              ),
            ),
            AppFilterActionBar(
              resetLabel: l10n.taskFilterReset,
              applyLabel: l10n.reportFilterGenerate,
              applyIcon: Assets.icons.icDocument,
              onReset: _reset,
              onApply: _apply,
            ),
          ],
        ),
      ),
    );
  }

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

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.label,
    required this.fromDate,
    required this.fromTime,
    required this.toDate,
    required this.toTime,
    required this.onFromDate,
    required this.onFromTime,
    required this.onToDate,
    required this.onToTime,
  });

  final String label;
  final String fromDate;
  final String fromTime;
  final String toDate;
  final String toTime;
  final VoidCallback onFromDate;
  final VoidCallback onFromTime;
  final VoidCallback onToDate;
  final VoidCallback onToTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget row(String date, String time, VoidCallback od, VoidCallback ot) =>
        Row(
          children: [
            Expanded(
              child: AppFilterPickerBox(
                value: date,
                placeholder: l10n.taskFilterDateHint,
                icon: Assets.icons.icCalendar,
                onTap: od,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppFilterPickerBox(
                value: time,
                placeholder: '00:00',
                icon: Assets.icons.icTuilconTime,
                onTap: ot,
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.h,
      children: [
        AppFilterFieldLabel(label),
        row(fromDate, fromTime, onFromDate, onFromTime),
        row(toDate, toTime, onToDate, onToTime),
      ],
    );
  }
}

/// Sonli qiymat oralig'i (dan/gacha).
class _AmountRange extends StatelessWidget {
  const _AmountRange({
    required this.label,
    required this.fromCtrl,
    required this.toCtrl,
  });

  final String label;
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: fromCtrl,
                hint: '${l10n.reportFilterFrom}: 0',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _NumberField(
                controller: toCtrl,
                hint: '${l10n.reportFilterTo}: 0',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
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
    );
  }
}
