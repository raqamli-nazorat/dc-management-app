import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../domain/entities/users_filter.dart';
import '../bloc/users_filter_bloc.dart';

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field { none, position, role, ordering }

/// Foydalanuvchilarni filtrlash sahifasi (`Routes.usersFilter`). Uch inline
/// dropdown: lavozim (`position` FK), rol (`roles`), tartiblash (`ordering`).
/// "Shakllantirish" bosilganda tuzilgan [UsersFilter] `pop` orqali qaytariladi;
/// qidiruv matni ([UsersFilter.search]) saqlanadi.
class UsersFilterPage extends StatelessWidget {
  const UsersFilterPage({required this.initial, super.key});

  final UsersFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UsersFilterBloc>(
      create: (_) =>
          getIt<UsersFilterBloc>()..add(const UsersFilterOptionsRequested()),
      child: _UsersFilterView(initial: initial),
    );
  }
}

class _UsersFilterView extends StatefulWidget {
  const _UsersFilterView({required this.initial});

  final UsersFilter initial;

  @override
  State<_UsersFilterView> createState() => _UsersFilterViewState();
}

class _UsersFilterViewState extends State<_UsersFilterView> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  int? _positionId;
  String? _role;
  UsersOrdering? _ordering;

  /// Statik rollar ro'yxati (API `RolesEnum`) — dropdown tartibida.
  static final _roles = [
    for (final r in RoleType.values)
      if (r != RoleType.unknown) r.name,
  ];

  @override
  void initState() {
    super.initState();
    _positionId = widget.initial.positionId;
    _role = widget.initial.role;
    _ordering = widget.initial.ordering;
  }

  void _toggle(_Field f) {
    setState(() => _open = _open == f ? _Field.none : f);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _pick(VoidCallback assign) {
    setState(() {
      assign();
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _reset() {
    setState(() {
      _positionId = null;
      _role = null;
      _ordering = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    Navigator.of(context).pop(
      UsersFilter(
        positionId: _positionId,
        role: _role,
        ordering: _ordering,
        search: widget.initial.search,
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
          child: BlocBuilder<UsersFilterBloc, UsersFilterState>(
            builder: (context, state) => Column(
              children: [
                AppFilterHeader(title: l10n.taskFilterTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.h,
                      children: [
                        _DropdownBox(
                          link: _links[_Field.position]!,
                          value: _positionName(state),
                          placeholder: l10n.usersFilterAllPositions,
                          onTap: () => _toggle(_Field.position),
                        ),
                        _DropdownBox(
                          link: _links[_Field.role]!,
                          value: _role == null
                              ? null
                              : RolePresentation.of(l10n, _role!).label,
                          placeholder: l10n.usersFilterAllRoles,
                          onTap: () => _toggle(_Field.role),
                        ),
                        _DropdownBox(
                          link: _links[_Field.ordering]!,
                          value: _ordering == null
                              ? null
                              : _orderingLabel(_ordering!, l10n),
                          placeholder: l10n.usersSortNameAsc,
                          onTap: () => _toggle(_Field.ordering),
                        ),
                      ],
                    ),
                  ),
                ),
                AppFilterActionBar(
                  resetLabel: l10n.taskFilterReset,
                  applyLabel: l10n.reportFilterGenerate,
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

  String? _positionName(UsersFilterState state) {
    if (_positionId == null) return null;
    for (final p in state.positions) {
      if (p.id == _positionId) return p.name;
    }
    return null;
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
    final state = context.read<UsersFilterBloc>().state;

    switch (_open) {
      case _Field.position:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final p in state.positions)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: p.id == _positionId,
                onTap: () => _pick(() => _positionId = p.id),
                child: _labelRow(p.name),
              ),
          ],
        );
      case _Field.role:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final r in _roles)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: r == _role,
                onTap: () => _pick(() => _role = r),
                child: _labelRow(RolePresentation.of(l10n, r).label),
              ),
          ],
        );
      case _Field.ordering:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final o in UsersOrdering.values)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: o == _ordering,
                onTap: () => _pick(() => _ordering = o),
                child: _labelRow(_orderingLabel(o, l10n)),
              ),
          ],
        );
      case _Field.none:
        return const SizedBox.shrink();
    }
  }

  Widget _labelRow(String text) => text
      .s(13.sp)
      .w(700)
      .c(AppColors.of(context).textStrong)
      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);
}

String _orderingLabel(UsersOrdering o, AppLocalizations l10n) => switch (o) {
  UsersOrdering.nameAsc => l10n.usersSortNameAsc,
  UsersOrdering.nameDesc => l10n.usersSortNameDesc,
  UsersOrdering.newestFirst => l10n.usersSortNewest,
  UsersOrdering.oldestFirst => l10n.usersSortOldest,
};

/// Yorliqsiz dropdown maydoni (Figma: faqat boxed qiymat + chevron) —
/// [AppFilterPickerBox]ning [LayerLink] bilan o'ralgan varianti.
class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.link,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final LayerLink link;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: link,
      child: AppFilterPickerBox(
        value: value ?? '',
        placeholder: placeholder,
        icon: Assets.icons.icTuilconChervonDown,
        onTap: onTap,
      ),
    );
  }
}
