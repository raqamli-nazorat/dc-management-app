import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../reports/domain/entities/expense_report.dart';
import '../../../reports/domain/entities/expense_report_filter.dart';
import '../../domain/entities/new_expense_request.dart';
import '../bloc/expense_request_create_bloc.dart';
import '../bloc/expense_request_options_bloc.dart';

/// Xarajat so'rovi yuborish sahifasi (`Routes.expenseRequestCreate`, Figma:
/// node 1146-686520 / 1881-398606). Faqat hisobchi/xodim ochadi (ro'yxatdagi
/// tugmadan). Loyiha/Toifa maydonlari xarajat turiga qarab yoqiladi/o'chadi;
/// to'lov turi "Karta orqali" bo'lsa karta maydoni chiqadi va profildagi karta
/// avto-to'ldiriladi (foydalanuvchi tahrirlashi mumkin).
class ExpenseRequestCreatePage extends StatelessWidget {
  const ExpenseRequestCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseRequestCreateBloc>(
          create: (_) => getIt<ExpenseRequestCreateBloc>(),
        ),
        BlocProvider<ExpenseRequestOptionsBloc>(
          create: (_) =>
              getIt<ExpenseRequestOptionsBloc>()
                ..add(const ExpenseRequestOptionsRequested()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
      ],
      child: const _CreateView(),
    );
  }
}

/// Ochilib turgan dropdown — bir vaqtda bittasi.
enum _Field { none, project, type, category, payment }

class _CreateView extends StatefulWidget {
  const _CreateView();

  @override
  State<_CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<_CreateView> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  ExpenseType? _type;
  int? _projectId;
  int? _categoryId;
  ExpensePaymentMethod? _payment;

  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();

  static const _types = [
    ExpenseType.withdrawal,
    ExpenseType.company,
    ExpenseType.other,
  ];
  static const _payments = [ExpensePaymentMethod.cash, ExpensePaymentMethod.card];

  /// Turi bo'yicha maydon qulflari (filtr sahifasi bilan bir xil): `withdrawal`
  /// — Loyiha ham Toifa ham yo'q; `company` — faqat Loyiha; `other` — faqat
  /// Toifa; tur tanlanmagan — ikkalasi ochiq.
  bool get _projectEnabled => _type == null || _type == ExpenseType.company;

  bool get _categoryEnabled => _type == null || _type == ExpenseType.other;

  bool get _cardVisible => _payment == ExpensePaymentMethod.card;

  void _applyTypeRules() {
    if (!_projectEnabled) _projectId = null;
    if (!_categoryEnabled) _categoryId = null;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    _cardCtrl.dispose();
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

  void _pick(VoidCallback assign) {
    setState(() {
      assign();
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  /// "Karta orqali" tanlanganida profildagi karta raqamini avto-to'ldirish
  /// (agar maydon bo'sh bo'lsa) — foydalanuvchi keyin tahrirlashi mumkin.
  void _prefillCardFromProfile() {
    if (!_cardVisible || _cardCtrl.text.isNotEmpty) return;
    final card = context.read<ProfileBloc>().state.profile?.cardNumber ?? '';
    if (card.isNotEmpty) _cardCtrl.text = card;
  }

  // ── Yuborish ──────────────────────────────────────────────────────────────

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final amount = _amountCtrl.text.replaceAll(' ', '').trim();
    final amountNum = num.tryParse(amount);

    final invalid =
        _type == null ||
        _payment == null ||
        amountNum == null ||
        amountNum <= 0 ||
        (_type == ExpenseType.company && _projectId == null) ||
        (_type == ExpenseType.other && _categoryId == null) ||
        (_cardVisible && _cardCtrl.text.trim().isEmpty);
    if (invalid) {
      AppToast.showError(context, title: l10n.expenseRequestCreateValidation);
      return;
    }

    context.read<ExpenseRequestCreateBloc>().add(
      ExpenseRequestCreateSubmitted(
        NewExpenseRequest(
          type: _type!,
          amount: amount,
          paymentMethod: _payment!,
          projectId: _type == ExpenseType.company ? _projectId : null,
          categoryId: _type == ExpenseType.other ? _categoryId : null,
          reason: _reasonCtrl.text.trim(),
          cardNumber: _cardVisible ? _cardCtrl.text.trim() : null,
        ),
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
          child: MultiBlocListener(
            listeners: [
              // So'rov yuborilgandan keyin: muvaffaqiyat toasti + ro'yxatga
              // qaytish (natija `true` — ro'yxat qayta yuklansin).
              BlocListener<ExpenseRequestCreateBloc, ExpenseRequestCreateState>(
                listenWhen: (p, c) => p.status != c.status,
                listener: _onCreateState,
              ),
              // Profil kech kelsa va karta tanlangan bo'lsa — avto-to'ldirish.
              BlocListener<ProfileBloc, ProfileState>(
                listenWhen: (p, c) => p.profile != c.profile,
                listener: (_, _) => setState(_prefillCardFromProfile),
              ),
            ],
            child: Column(
              children: [
                _Header(title: l10n.expenseRequestCreateTitle),
                Expanded(
                  child:
                      BlocBuilder<
                        ExpenseRequestOptionsBloc,
                        ExpenseRequestOptionsState
                      >(
                        builder: (context, state) => SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16.h,
                            children: [
                              AppFilterFieldBox(
                                label: l10n.expenseRequestCreateProjectLabel,
                                value: _optionTitle(
                                  state.options?.projects,
                                  _projectId,
                                ),
                                placeholder: l10n.expenseReportProjectHint,
                                enabled: _projectEnabled,
                                link: _links[_Field.project],
                                onTap: () => _toggle(_Field.project),
                                onClear: () =>
                                    setState(() => _projectId = null),
                              ),
                              AppFilterFieldBox(
                                label: l10n.expenseReportType,
                                value: _type == null
                                    ? null
                                    : _typeLabel(_type!, l10n),
                                placeholder: l10n.ledgerFilterExpenseTypeHint,
                                link: _links[_Field.type],
                                onTap: () => _toggle(_Field.type),
                                onClear: () => setState(() {
                                  _type = null;
                                  _applyTypeRules();
                                }),
                              ),
                              AppFilterFieldBox(
                                label: l10n.expenseRequestFilterCategory,
                                value: _optionTitle(
                                  state.options?.categories,
                                  _categoryId,
                                ),
                                placeholder:
                                    l10n.expenseRequestFilterCategoryHint,
                                enabled: _categoryEnabled,
                                link: _links[_Field.category],
                                onTap: () => _toggle(_Field.category),
                                onClear: () =>
                                    setState(() => _categoryId = null),
                              ),
                              _LabeledField(
                                label: l10n.expenseRequestCreateAmountLabel,
                                child: _AmountField(controller: _amountCtrl),
                              ),
                              _LabeledField(
                                label: l10n.expenseRequestReasonField,
                                child: _ReasonField(controller: _reasonCtrl),
                              ),
                              AppFilterFieldBox(
                                label: l10n.expenseReportPaymentMethod,
                                value: _payment == null
                                    ? null
                                    : _paymentLabel(_payment!, l10n),
                                placeholder:
                                    l10n.expenseRequestCreatePaymentHint,
                                link: _links[_Field.payment],
                                onTap: () => _toggle(_Field.payment),
                                onClear: () => setState(() => _payment = null),
                              ),
                              if (_cardVisible)
                                _LabeledField(
                                  label: l10n.expenseRequestCreateCardLabel,
                                  child: _CardField(controller: _cardCtrl),
                                ),
                            ],
                          ),
                        ),
                      ),
                ),
                _SubmitBar(
                  label: l10n.expenseRequestCreateSubmit,
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCreateState(
    BuildContext context,
    ExpenseRequestCreateState state,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (state.status) {
      case ExpenseRequestCreateStatus.success:
        AppToast.showSuccess(
          context,
          title: l10n.expenseRequestCreateSuccess,
          message: l10n.expenseRequestCreateSuccessMessage,
        );
        Navigator.of(context).pop(true);
      case ExpenseRequestCreateStatus.failure:
        AppToast.showError(
          context,
          title: l10n.commonError,
          message: state.failure?.message,
        );
      case ExpenseRequestCreateStatus.initial:
      case ExpenseRequestCreateStatus.submitting:
        break;
    }
  }

  String? _optionTitle(List<ExpenseFilterOption>? options, int? id) {
    if (options == null || id == null) return null;
    for (final o in options) {
      if (o.id == id) return o.title;
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
    final options = context.read<ExpenseRequestOptionsBloc>().state.options;

    switch (_open) {
      case _Field.project:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final o in options?.projects ?? const <ExpenseFilterOption>[])
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: o.id == _projectId,
                onTap: () => _pick(() => _projectId = o.id),
                child: _labelRow(o.title),
              ),
          ],
        );
      case _Field.type:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final t in _types)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: t == _type,
                onTap: () => _pick(() {
                  _type = t;
                  _applyTypeRules();
                }),
                child: _labelRow(_typeLabel(t, l10n)),
              ),
          ],
        );
      case _Field.category:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final o
                in options?.categories ?? const <ExpenseFilterOption>[])
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: o.id == _categoryId,
                onTap: () => _pick(() => _categoryId = o.id),
                child: _labelRow(o.title),
              ),
          ],
        );
      case _Field.payment:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final p in _payments)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: p == _payment,
                onTap: () => _pick(() {
                  _payment = p;
                  _prefillCardFromProfile();
                }),
                child: _labelRow(_paymentLabel(p, l10n)),
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

String _typeLabel(ExpenseType t, AppLocalizations l10n) => switch (t) {
  ExpenseType.withdrawal => l10n.expenseReportTypeWithdrawal,
  ExpenseType.company => l10n.expenseReportTypeCompany,
  ExpenseType.other => l10n.expenseReportTypeOther,
  ExpenseType.unknown => '',
};

String _paymentLabel(ExpensePaymentMethod p, AppLocalizations l10n) =>
    switch (p) {
      ExpensePaymentMethod.cash => l10n.expenseReportPaymentCash,
      ExpensePaymentMethod.card => l10n.expenseReportPaymentCard,
      ExpensePaymentMethod.unknown => '',
    };

/// Sarlavha qatori: markazda nom + o'ngda yopish (×).
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
                .h(28 / 17)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Assets.icons.icClose.svg(
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}

/// Yorliq + maydon (dropdown maydonlaridagi label ko'rinishi bilan bir xil).
class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [AppFilterFieldLabel(label), child],
    );
  }
}

/// Summa maydoni — ming ajratkichi, faqat musbat butun (formatter raqamsizni
/// tashlaydi, shu bois manfiy kiritib bo'lmaydi).
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
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
              keyboardType: TextInputType.number,
              inputFormatters: [AppThousandsInputFormatter()],
              style: style,
              cursorColor: colors.accentSub,
              decoration: InputDecoration.collapsed(
                hintText: l10n.expenseRequestCreateAmountHint,
                hintStyle: style.copyWith(color: colors.textSub),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Karta raqami maydoni — raqam klaviaturasi, 20 belgigacha (backend limiti).
class _CardField extends StatelessWidget {
  const _CardField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: style,
              cursorColor: colors.accentSub,
              decoration: InputDecoration.collapsed(
                hintText: l10n.expenseRequestCreateCardHint,
                hintStyle: style.copyWith(color: colors.textSub),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sababi — ko'p qatorli matn maydoni.
class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          style: style,
          cursorColor: colors.accentSub,
          decoration: InputDecoration.collapsed(
            hintText: l10n.expenseRequestCreateReasonHint,
            hintStyle: style.copyWith(color: colors.textSub),
          ),
        ),
      ),
    );
  }
}

/// Pastdagi to'liq kenglikdagi "So'rov yuborish" tugmasi — yuborilayotganda
/// spinner ko'rsatadi va qayta bosishni bloklaydi.
class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.label, required this.onSubmit});

  final String label;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        child: BlocBuilder<
          ExpenseRequestCreateBloc,
          ExpenseRequestCreateState
        >(
          builder: (context, state) {
            final busy =
                state.status == ExpenseRequestCreateStatus.submitting;
            return InkWell(
              onTap: busy ? null : onSubmit,
              borderRadius: BorderRadius.circular(16.r),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.accentStrong,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: SizedBox(
                  height: 52.h,
                  child: Center(
                    child: busy
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              color: colors.textWhite,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Assets.icons.icArrowRightExit.svg(
                                width: 20.w,
                                height: 20.w,
                                colorFilter: ColorFilter.mode(
                                  colors.textWhite,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              label
                                  .s(15.sp)
                                  .w(800)
                                  .h(24 / 15)
                                  .c(colors.textWhite),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
