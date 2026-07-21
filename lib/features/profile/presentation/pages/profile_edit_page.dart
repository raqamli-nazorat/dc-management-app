import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_file_actions.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/profile_update.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/change_password_dialog.dart';
import '../widgets/role_switch_dialog.dart';

class ProfileEditPage extends StatelessWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
      child: const _ProfileEditView(),
    );
  }
}

class _ProfileEditView extends StatelessWidget {
  const _ProfileEditView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            AppFilterHeader(title: l10n.profilePersonalInfo),
            Expanded(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listenWhen: (previous, current) =>
                    previous.status == ProfileStatus.saving &&
                    current.status != ProfileStatus.saving,
                listener: (context, state) {
                  if (state.status == ProfileStatus.success) {
                    AppToast.showSuccess(
                      context,
                      title: l10n.profileUpdateSuccess,
                    );
                    context.pop(true);
                  } else if (state.status == ProfileStatus.failure) {
                    AppToast.showError(
                      context,
                      title: l10n.commonError,
                      message: state.failure?.message,
                    );
                  }
                },
                builder: (context, state) {
                  if (state.profile == null) {
                    if (state.status == ProfileStatus.failure) {
                      return _ProfileEditError(failure: state.failure);
                    }
                    return Center(
                      child: CircularProgressIndicator(color: colors.accentSub),
                    );
                  }
                  return _ProfileEditBody(
                    profile: state.profile!,
                    isSaving: state.status == ProfileStatus.saving,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileEditBody extends StatefulWidget {
  const _ProfileEditBody({required this.profile, required this.isSaving});

  final Profile profile;
  final bool isSaving;

  @override
  State<_ProfileEditBody> createState() => _ProfileEditBodyState();
}

class _ProfileEditBodyState extends State<_ProfileEditBody> {
  late final TextEditingController _phoneController;
  late final TextEditingController _cardController;
  late final TextEditingController _firstLinkController;
  late final TextEditingController _secondLinkController;
  late final List<String> _extraLinks;
  late final String _passportSeries;
  late final String _passportNumber;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final links = widget.profile.socialLinks;
    _phoneController = TextEditingController(
      text: _formatPhone(widget.profile.phoneNumber),
    );
    _cardController = TextEditingController(
      text: _formatCardNumber(widget.profile.cardNumber),
    );
    _firstLinkController = TextEditingController(
      text: links.isEmpty ? '' : links.first,
    );
    _secondLinkController = TextEditingController(
      text: links.length > 1 ? links[1] : '',
    );
    final passport = RegExp(
      r'^([A-Za-z]*)\s*(.*)$',
    ).firstMatch(widget.profile.passportSeries.trim());
    _passportSeries = passport?.group(1) ?? '';
    _passportNumber = passport?.group(2) ?? '';
    _extraLinks = links.length > 2 ? links.sublist(2) : const [];
    for (final controller in _controllers) {
      controller.addListener(_onChanged);
    }
  }

  List<TextEditingController> get _controllers => [
    _phoneController,
    _cardController,
    _firstLinkController,
    _secondLinkController,
  ];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_onChanged)
        ..dispose();
    }
    super.dispose();
  }

  void _onChanged() => setState(() {});

  List<String> get _currentLinks => [
    _firstLinkController.text.trim(),
    _secondLinkController.text.trim(),
    ..._extraLinks,
  ].where((link) => link.isNotEmpty).toList();

  bool _sameLinks(List<String> first, List<String> second) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }
    return true;
  }

  Map<String, dynamic> _changedFields() {
    final profile = widget.profile;
    final fields = <String, dynamic>{};
    final phone = _normalizePhone(_phoneController.text);
    final card = _digitsOnly(_cardController.text);
    final links = _currentLinks;

    if (phone != profile.phoneNumber) fields['phone_number'] = phone;
    if (card != profile.cardNumber) fields['card_number'] = card;
    if (!_sameLinks(links, profile.socialLinks)) fields['social_links'] = links;
    return fields;
  }

  ProfileUpdate _update() =>
      ProfileUpdate(fields: _changedFields(), avatarPath: _avatarPath);

  void _submit() {
    final fields = _changedFields();
    if ((fields.isEmpty && _avatarPath == null) || widget.isSaving) {
      return;
    }

    final phone = fields['phone_number'];
    if (phone is String && !RegExp(r'^\+998\d{9}$').hasMatch(phone)) {
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).profilePhoneInvalid,
      );
      return;
    }
    context.read<ProfileBloc>().add(ProfileUpdateSubmitted(_update()));
  }

  Future<void> _pickAvatar() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      final file = result?.files.single;
      if (file?.path == null) return;
      setState(() => _avatarPath = file!.path);
    } on Object {
      if (!mounted) return;
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).commonError,
      );
    }
  }

  void _openRoleSwitch() {
    final profile = widget.profile;
    final l10n = AppLocalizations.of(context);
    final profileBloc = context.read<ProfileBloc>();
    final sessionBloc = context.read<SessionBloc>();

    showRoleSwitchDialog(
      context,
      roles: profile.roles,
      activeRole: profile.activeRole,
      onSwitched: (role) {
        sessionBloc.add(SessionRoleSelected(role));
        profileBloc.add(const ProfileRequested());
        final label = RolePresentation.of(l10n, role).label;
        AppToast.showSuccess(
          context,
          title: l10n.roleSwitchedTitle(label),
          message: l10n.roleSwitchedSubtitle(label),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = widget.profile;
    final hasChanges = _changedFields().isNotEmpty || _avatarPath != null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(
                  profile: profile,
                  avatarPath: _avatarPath,
                  onAvatarTap: _pickAvatar,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _ReadonlyField(
                        label: l10n.userDetailSalary,
                        value: Formatters.formatAmountComma(
                          profile.fixedSalary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: _ReadonlyField(
                        label: l10n.userDetailBalance,
                        value: Formatters.formatAmountComma(profile.balance),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _EditableField(
                  label: l10n.userDetailPhone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [_PhoneInputFormatter()],
                ),
                SizedBox(height: 8.h),
                _EditableField(
                  label: l10n.userDetailCard,
                  controller: _cardController,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [_CardNumberFormatter()],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: _ReadonlyField(
                        label: l10n.reportFilterRegion,
                        value: profile.region,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: _ReadonlyField(
                        label: l10n.userDetailDistrict,
                        value: profile.district,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                _PassportInputField(
                  label: l10n.userDetailPassport,
                  series: _passportSeries,
                  number: _passportNumber,
                ),
                SizedBox(height: 8.h),
                _PassportFileField(
                  label: l10n.userDetailPassportImage,
                  url: profile.passportImage,
                ),
                SizedBox(height: 8.h),
                _EditableField(
                  label: l10n.profileLinkLabel(1),
                  controller: _firstLinkController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(height: 8.h),
                _EditableField(
                  label: l10n.profileLinkLabel(2),
                  controller: _secondLinkController,
                  keyboardType: TextInputType.url,
                ),
                SizedBox(height: 12.h),
                _ProfileStatusRow(
                  icon: Assets.icons.icPersonalInformationIcon,
                  label: l10n.userDetailPosition,
                  value: profile.position,
                ),
                SizedBox(height: 8.h),
                _ProfileStatusRow(
                  icon: Assets.icons.icPersonalInformationSwitch,
                  label: l10n.userDetailRole,
                  value: RolePresentation.of(l10n, profile.activeRole).label,
                  onTap: _openRoleSwitch,
                ),
              ],
            ),
          ),
        ),
        if (hasChanges)
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
              child: CustomButton(
                label: l10n.profileSave,
                isLoading: widget.isSaving,
                onPressed: _submit,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.avatarPath,
    required this.onAvatarTap,
  });

  final Profile profile;
  final String? avatarPath;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        InkWell(
          onTap: onAvatarTap,
          borderRadius: BorderRadius.circular(42.r),
          child: avatarPath == null
              ? TuiAvatar(
                  initial: profile.username,
                  avatarUrl: profile.avatar,
                  size: 84,
                )
              : ClipOval(
                  child: Image.file(
                    File(avatarPath!),
                    width: 84.w,
                    height: 84.w,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              profile.username
                  .s(15.sp)
                  .w(800)
                  .h(24 / 15)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 12.h),
              InkWell(
                onTap: () => showChangePasswordDialog(context),
                borderRadius: BorderRadius.circular(8.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation1Alt,
                    border: Border.all(color: colors.strokeSub, width: 1.w),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        l10n.securityChangePassword
                            .s(11.sp)
                            .w(800)
                            .h(16 / 11)
                            .c(colors.textStrong),
                        SizedBox(width: 8.w),
                        Assets.icons.icLock.svg(
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
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableField extends StatefulWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(widget.label),
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundBase,
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colors.strokeAccent
                    : colors.strokeSub,
                width: _focusNode.hasFocus ? 1.5.w : 1.w,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 44.h,
                child: Center(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    inputFormatters: widget.inputFormatters,
                    style: textStyle,
                    cursorColor: colors.accentSub,
                    decoration: const InputDecoration.collapsed(hintText: ''),
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

class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    this.textAlign = TextAlign.start,
  });

  final String label;
  final String value;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final field = DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: Align(
            alignment: textAlign == TextAlign.end
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: (value.isEmpty ? '-' : value)
                .s(13.sp)
                .w(500)
                .h(20 / 13)
                .c(colors.textStrong)
                .a(textAlign)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [AppFilterFieldLabel(label), field],
    );
  }
}

class _PassportInputField extends StatelessWidget {
  const _PassportInputField({
    required this.label,
    required this.series,
    required this.number,
  });

  final String label;
  final String series;
  final String number;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    Widget box(String value) => DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: Align(
            alignment: Alignment.centerLeft,
            child: (value.isEmpty ? '-' : value)
                .s(13.sp)
                .w(500)
                .h(20 / 13)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        Row(
          children: [
            SizedBox(width: 80.w, child: box(series)),
            SizedBox(width: 8.w),
            Expanded(child: box(number)),
          ],
        ),
      ],
    );
  }
}

class _PassportFileField extends StatelessWidget {
  const _PassportFileField({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final segments = Uri.tryParse(url)?.pathSegments ?? const [];
    final name = segments.isEmpty ? url : Uri.decodeComponent(segments.last);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors).copyWith(
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SizedBox(
              height: 44.h,
              child: Row(
                children: [
                  Assets.icons.icDocument.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: name
                        .s(13.sp)
                        .w(500)
                        .h(20 / 13)
                        .c(colors.textSub)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  AppFileActions(
                    url: url,
                    openLabel: l10n.commonOpenFile,
                    downloadLabel: l10n.commonDownloadFile,
                    errorTitle: l10n.commonError,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileStatusRow extends StatelessWidget {
  const _ProfileStatusRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final labelWidget = Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SizedBox(
            width: 32.w,
            height: 32.w,
            child: Center(
              child: icon.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: label
              .s(13.sp)
              .w(800)
              .h(20 / 13)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
    final valueWidget = DecoratedBox(
      decoration: appFilterFieldDecoration(
        colors,
      ).copyWith(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 32.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 120.w),
                child: (value.isEmpty ? '-' : value)
                    .s(13.sp)
                    .w(500)
                    .h(20 / 13)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (onTap != null) ...[
                SizedBox(width: 4.w),
                Assets.icons.icTuilconChervonDown.svg(
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
    );

    return Row(
      children: [
        Expanded(child: labelWidget),
        SizedBox(width: 8.w),
        if (onTap == null)
          valueWidget
        else
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: valueWidget,
          ),
      ],
    );
  }
}

String _digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String _formatPhone(String value) {
  var digits = _digitsOnly(value);
  if (digits.startsWith('998')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length > 9) digits = digits.substring(0, 9);

  final groups = <String>[];
  if (digits.length >= 2) {
    groups.add(digits.substring(0, 2));
    digits = digits.substring(2);
  } else if (digits.isNotEmpty) {
    groups.add(digits);
    digits = '';
  }
  for (final length in [3, 2, 2]) {
    if (digits.isEmpty) break;
    final take = digits.length < length ? digits.length : length;
    groups.add(digits.substring(0, take));
    digits = digits.substring(take);
  }
  return groups.isEmpty ? '' : '+998 ${groups.join(' ')}';
}

String _normalizePhone(String value) {
  var digits = _digitsOnly(value);
  if (digits.startsWith('998')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits.isEmpty ? '' : '+998$digits';
}

String _formatCardNumber(String value) {
  final digits = _digitsOnly(value);
  final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
  final groups = <String>[];
  for (var index = 0; index < limited.length; index += 4) {
    final end = index + 4 < limited.length ? index + 4 : limited.length;
    groups.add(limited.substring(index, end));
  }
  return groups.join(' ');
}

class _PhoneInputFormatter extends TextInputFormatter {
  const _PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _formatPhone(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  const _CardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _formatCardNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ProfileEditError extends StatelessWidget {
  const _ProfileEditError({required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (failure is NetworkFailure ? l10n.networkError : l10n.commonError)
              .s(14.sp)
              .w(500)
              .c(colors.textSub),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () =>
                context.read<ProfileBloc>().add(const ProfileRequested()),
            child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
          ),
        ],
      ),
    );
  }
}
