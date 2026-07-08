import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../domain/entities/meeting_filter.dart';
import '../bloc/meeting_filter_bloc.dart';

enum _Field { none, organizer, project }

class MeetingFilterPage extends StatelessWidget {
  const MeetingFilterPage({required this.initial, super.key});

  final MeetingFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeetingFilterBloc>(
      create: (_) =>
          getIt<MeetingFilterBloc>()
            ..add(const MeetingFilterOptionsRequested()),
      child: _MeetingFilterView(initial: initial),
    );
  }
}

class _MeetingFilterView extends StatefulWidget {
  const _MeetingFilterView({required this.initial});

  final MeetingFilter initial;

  @override
  State<_MeetingFilterView> createState() => _MeetingFilterViewState();
}

class _MeetingFilterViewState extends State<_MeetingFilterView> {
  final _portalCtrl = OverlayPortalController();
  final _organizerLink = LayerLink();
  final _projectLink = LayerLink();

  _Field _open = _Field.none;
  int? _organizerId;
  int? _projectId;
  DateTime? _fromDate;
  DateTime? _toDate;
  late String _search;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _organizerId = f.organizerId;
    _projectId = f.projectId;
    _fromDate = f.startDateGte;
    _toDate = f.startDateLte;
    _search = f.search ?? '';
  }

  void _toggle(_Field field) {
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == field ? _Field.none : field);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _selectOrganizer(int id) {
    setState(() {
      _organizerId = id;
      _projectId = null;
      _fromDate = null;
      _toDate = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _selectProject(int id) {
    setState(() {
      _projectId = id;
      _fromDate = null;
      _toDate = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: (from ? _fromDate : _toDate) ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _fromDate = picked : _toDate = picked);
    }
  }

  void _reset() {
    setState(() {
      _organizerId = null;
      _projectId = null;
      _fromDate = null;
      _toDate = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    Navigator.of(context).pop(
      MeetingFilter(
        organizerId: _organizerId,
        projectId: _projectId,
        search: _search,
        startDateGte: _fromDate,
        startDateLte: _toDate,
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
        child: OverlayPortal(
          controller: _portalCtrl,
          overlayChildBuilder: _buildOverlay,
          child: BlocBuilder<MeetingFilterBloc, MeetingFilterState>(
            builder: (context, state) => Column(
              children: [
                AppFilterHeader(title: l10n.taskFilterTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppFilterFieldBox(
                          label: l10n.meetingFilterOrganizer,
                          value: _userName(state, _organizerId),
                          placeholder: l10n.meetingFilterOrganizerHint,
                          link: _organizerLink,
                          onTap: () => _toggle(_Field.organizer),
                          onClear: () => setState(() {
                            _organizerId = null;
                            _projectId = null;
                            _fromDate = null;
                            _toDate = null;
                          }),
                        ),
                        if (_organizerId != null) ...[
                          SizedBox(height: 12.h),
                          AppFilterFieldBox(
                            label: l10n.taskCreateFieldProject,
                            value: _projectName(state, _projectId),
                            placeholder: l10n.taskCreateProjectHint,
                            link: _projectLink,
                            onTap: () => _toggle(_Field.project),
                            onClear: () => setState(() {
                              _projectId = null;
                              _fromDate = null;
                              _toDate = null;
                            }),
                          ),
                        ],
                        if (_projectId != null) ...[
                          SizedBox(height: 12.h),
                          _DateRange(
                            label: l10n.meetingFilterStartDateRange,
                            dateHint: l10n.taskFilterDateHint,
                            fromDate: _fmtDate(_fromDate),
                            toDate: _fmtDate(_toDate),
                            onFromDate: () => _pickDate(true),
                            onToDate: () => _pickDate(false),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                AppFilterActionBar(
                  resetLabel: l10n.taskFilterReset,
                  applyLabel: l10n.taskFilterApply,
                  onReset: _reset,
                  onApply: _apply,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final link = switch (_open) {
      _Field.organizer => _organizerLink,
      _Field.project => _projectLink,
      _Field.none => null,
    };
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
    final state = context.read<MeetingFilterBloc>().state;
    return AppFilterDropdownBox(
      emptyText: AppLocalizations.of(context).statEmpty,
      children: switch (_open) {
        _Field.organizer => [
          for (final user in state.users)
            AppFilterDropdownItem(
              height: 48,
              selected: user.id == _organizerId,
              onTap: () => _selectOrganizer(user.id),
              child: _OptionText(title: user.username, subtitle: user.position),
            ),
        ],
        _Field.project => [
          for (final project in state.projects)
            AppFilterDropdownItem(
              height: 48,
              selected: project.id == _projectId,
              onTap: () => _selectProject(project.id),
              child: _ProjectOption(project: project),
            ),
        ],
        _Field.none => const [],
      },
    );
  }
}

String? _userName(MeetingFilterState state, int? id) {
  if (id == null) return null;
  for (final user in state.users) {
    if (user.id == id) return user.username;
  }
  return null;
}

String? _projectName(MeetingFilterState state, int? id) {
  if (id == null) return null;
  for (final project in state.projects) {
    if (project.id == id) return project.title;
  }
  return null;
}

String _fmtDate(DateTime? date) {
  if (date == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.label,
    required this.dateHint,
    required this.fromDate,
    required this.toDate,
    required this.onFromDate,
    required this.onToDate,
  });

  final String label;
  final String dateHint;
  final String fromDate;
  final String toDate;
  final VoidCallback onFromDate;
  final VoidCallback onToDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        Row(
          children: [
            Expanded(
              child: AppFilterPickerBox(
                value: fromDate,
                placeholder: dateHint,
                icon: Assets.icons.icCalendar,
                onTap: onFromDate,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppFilterPickerBox(
                value: toDate,
                placeholder: dateHint,
                icon: Assets.icons.icCalendar,
                onTap: onToDate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OptionText extends StatelessWidget {
  const _OptionText({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        title
            .s(13.sp)
            .w(500)
            .h(20 / 13)
            .c(colors.textStrong)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle.isNotEmpty)
          subtitle
              .s(11.sp)
              .w(500)
              .h(16 / 11)
              .c(colors.textSub)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _ProjectOption extends StatelessWidget {
  const _ProjectOption({required this.project});

  final ProjectShort project;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: _OptionText(
            title: project.title,
            subtitle: project.description,
          ),
        ),
        SizedBox(width: 12.w),
        _fmtDate(project.deadline)
            .s(11.sp)
            .w(500)
            .h(16 / 11)
            .c(colors.iconSub)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
