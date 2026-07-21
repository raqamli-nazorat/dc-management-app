import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/contact_input_formatters.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_editable_field.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../../reports/domain/entities/user_report_filter.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../domain/entities/new_user.dart';
import '../bloc/user_create_bloc.dart';

class UserCreatePage extends StatelessWidget {
  const UserCreatePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider<UserCreateBloc>(
    create: (_) =>
        getIt<UserCreateBloc>()..add(const UserCreateOptionsRequested()),
    child: const _UserCreateView(),
  );
}

class _UserCreateView extends StatefulWidget {
  const _UserCreateView();

  @override
  State<_UserCreateView> createState() => _UserCreateViewState();
}

class _UserCreateViewState extends State<_UserCreateView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _salary = TextEditingController();
  final _phone = TextEditingController();
  final _card = TextEditingController();
  final _passportSeries = TextEditingController();
  final _passportNumber = TextEditingController();
  final _links = <TextEditingController>[TextEditingController()];

  Region? _region;
  District? _district;
  Position? _position;
  String? _role;
  String? _avatarPath;
  String? _passportImagePath;

  @override
  void dispose() {
    for (final controller in [
      _name,
      _password,
      _salary,
      _phone,
      _card,
      _passportSeries,
      _passportNumber,
      ..._links,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage({required bool avatar}) async {
    try {
      final path = (await FilePicker.platform.pickFiles(
        type: FileType.image,
      ))?.files.single.path;
      if (path == null || !mounted) return;
      setState(() {
        if (avatar) {
          _avatarPath = path;
        } else {
          _passportImagePath = path;
        }
      });
    } on Object {
      if (mounted) {
        AppToast.showError(
          context,
          title: AppLocalizations.of(context).commonError,
        );
      }
    }
  }

  void _selectRegion(Region region) {
    setState(() {
      _region = region;
      _district = null;
    });
    context.read<UserCreateBloc>().add(UserCreateRegionSelected(region.id));
  }

  void _submit(UserCreateState state) {
    final l10n = AppLocalizations.of(context);
    if (state.submitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_region == null ||
        _district == null ||
        _position == null ||
        _role == null) {
      AppToast.showError(context, title: l10n.userCreateRequiredError);
      return;
    }
    context.read<UserCreateBloc>().add(
      UserCreateSubmitted(
        NewUser(
          username: _name.text.trim(),
          password: _password.text,
          confirmPassword: _password.text,
          phoneNumber: normalizePhoneNumber(_phone.text),
          cardNumber: digitsOnly(_card.text),
          fixedSalary: Formatters.normalizeAmount(_salary.text),
          regionId: _region!.id,
          districtId: _district!.id,
          positionId: _position!.id,
          roles: [_role!],
          passportSeries: '${_passportSeries.text}${_passportNumber.text}',
          socialLinks: [
            for (final controller in _links)
              if (controller.text.trim().isNotEmpty) controller.text.trim(),
          ],
          avatarPath: _avatarPath,
          passportImagePath: _passportImagePath,
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
        child: BlocConsumer<UserCreateBloc, UserCreateState>(
          listenWhen: (previous, current) =>
              previous.success != current.success ||
              previous.failure != current.failure,
          listener: (context, state) {
            if (state.success) {
              AppToast.showSuccess(context, title: l10n.userCreateSuccess);
              context.pop(true);
            } else if (state.failure != null) {
              AppToast.showError(
                context,
                title: l10n.commonError,
                message: state.failure!.message,
              );
            }
          },
          builder: (context, state) => Column(
            children: [
              AppFilterHeader(title: l10n.userCreateTitle),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AvatarPicker(path: _avatarPath, onTap: _pickImage),
                        SizedBox(height: 16.h),
                        AppEditableField(
                          controller: _name,
                          label: l10n.userDetailFullName,
                          hintText: l10n.userCreateNameHint,
                          textInputAction: TextInputAction.next,
                          validator: _required(l10n),
                        ),
                        SizedBox(height: 12.h),
                        AppEditableField(
                          controller: _password,
                          label: l10n.userCreatePassword,
                          hintText: l10n.userCreatePassword,
                          obscureText: true,
                          showObscureToggle: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: _required(l10n),
                        ),
                        SizedBox(height: 12.h),
                        AppEditableField(
                          controller: _salary,
                          label: l10n.userDetailSalary,
                          hintText: '0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [const AmountInputFormatter()],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null;
                            }
                            return RegExp(
                                  r'^\d{1,3}(?: \d{3})*(?:,\d{1,2})?$',
                                ).hasMatch(value.trim())
                                ? null
                                : l10n.userCreateSalaryInvalid;
                          },
                        ),
                        SizedBox(height: 12.h),
                        _ResponsivePair(
                          first: AppEditableField(
                            controller: _phone,
                            label: l10n.userDetailPhone,
                            prefixText: '+998 ',
                            hintText: '90 123 45 67',
                            keyboardType: TextInputType.number,
                            inputFormatters: const [
                              PhoneNumberInputFormatter(
                                includeCountryPrefix: false,
                              ),
                            ],
                            validator: (value) =>
                                RegExp(
                                  r'^\+998\d{9}$',
                                ).hasMatch(normalizePhoneNumber(value ?? ''))
                                ? null
                                : l10n.profilePhoneInvalid,
                          ),
                          second: AppEditableField(
                            controller: _card,
                            label: l10n.userDetailCard,
                            hintText: '0000 0000 0000 0000',
                            keyboardType: TextInputType.number,
                            inputFormatters: const [CardNumberInputFormatter()],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _ResponsivePair(
                          first: _PickerField(
                            label: l10n.reportFilterRegion,
                            value: _region?.name,
                            placeholder: l10n.reportFilterRegionHint,
                            enabled: !state.optionsLoading,
                            loading: state.optionsLoading,
                            onTap: () async {
                              final region = await _showPicker<Region>(
                                context,
                                title: l10n.reportFilterRegion,
                                values: state.regions,
                                label: (value) => value.name,
                              );
                              if (region != null && mounted) {
                                _selectRegion(region);
                              }
                            },
                          ),
                          second: _PickerField(
                            label: l10n.userDetailDistrict,
                            value: _district?.name,
                            placeholder: l10n.userCreateDistrictHint,
                            enabled: _region != null && !state.districtsLoading,
                            loading: state.districtsLoading,
                            onTap: () async {
                              final district = await _showPicker<District>(
                                context,
                                title: l10n.userDetailDistrict,
                                values: state.districts,
                                label: (value) => value.name,
                              );
                              if (district != null && mounted) {
                                setState(() => _district = district);
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _PassportFields(
                          series: _passportSeries,
                          number: _passportNumber,
                        ),
                        SizedBox(height: 12.h),
                        _FilePickerField(
                          label: l10n.userDetailPassportImage,
                          path: _passportImagePath,
                          onTap: () => _pickImage(avatar: false),
                        ),
                        SizedBox(height: 16.h),
                        _PickerField(
                          label: l10n.userDetailPosition,
                          value: _position?.name,
                          placeholder: l10n.reportFilterPositionHint,
                          enabled: !state.optionsLoading,
                          loading: state.optionsLoading,
                          onTap: () async {
                            final position = await _showPicker<Position>(
                              context,
                              title: l10n.userDetailPosition,
                              values: state.positions,
                              label: (value) => value.name,
                            );
                            if (position != null && mounted) {
                              setState(() => _position = position);
                            }
                          },
                        ),
                        SizedBox(height: 12.h),
                        _PickerField(
                          label: l10n.userDetailRole,
                          value: _role == null
                              ? null
                              : RolePresentation.of(l10n, _role!).label,
                          placeholder: l10n.usersFilterAllRoles,
                          onTap: () async {
                            final role = await _showPicker<String>(
                              context,
                              title: l10n.userDetailRole,
                              values: [
                                for (final role in RoleType.values)
                                  if (role != RoleType.unknown) role.name,
                              ],
                              label: (value) =>
                                  RolePresentation.of(l10n, value).label,
                            );
                            if (role != null && mounted) {
                              setState(() => _role = role);
                            }
                          },
                        ),
                        SizedBox(height: 16.h),
                        for (var index = 0; index < _links.length; index++) ...[
                          AppEditableField(
                            controller: _links[index],
                            label: l10n.profileLinkLabel(index + 1),
                            hintText: l10n.userCreateLinkHint,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(height: 12.h),
                        ],
                        InkWell(
                          onTap: () => setState(
                            () => _links.add(TextEditingController()),
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Assets.icons.icPlus.svg(
                              width: 18.w,
                              height: 18.w,
                              colorFilter: ColorFilter.mode(
                                colors.iconStrong,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                  child: CustomButton(
                    label: l10n.userCreateSubmit,
                    isLoading: state.submitting,
                    onPressed: () => _submit(state),
                    leading: Assets.icons.icPlus.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.textWhite,
                        BlendMode.srcIn,
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

  String? Function(String?) _required(AppLocalizations l10n) =>
      (value) => value == null || value.trim().isEmpty
      ? l10n.userCreateRequiredError
      : null;
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.first, required this.second});

  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => constraints.maxWidth < 560.w
        ? Column(
            children: [
              first,
              SizedBox(height: 12.h),
              second,
            ],
          )
        : Row(
            children: [
              Expanded(child: first),
              SizedBox(width: 12.w),
              Expanded(child: second),
            ],
          ),
  );
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFilterFieldLabel(label),
          InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12.r),
            child: DecoratedBox(
              decoration: appFilterFieldDecoration(colors),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: SizedBox(
                  height: 44.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: (value ?? placeholder)
                            .s(13.sp)
                            .w(500)
                            .c(
                              value == null
                                  ? colors.textSub
                                  : colors.textStrong,
                            )
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      if (loading)
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: colors.accentSub,
                          ),
                        )
                      else
                        Assets.icons.icTuilconChervonDown.svg(
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
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({required this.path, required this.onTap});

  final String? path;
  final Future<void> Function({required bool avatar}) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: InkWell(
        onTap: () => onTap(avatar: true),
        borderRadius: BorderRadius.circular(42.r),
        child: Column(
          children: [
            ClipOval(
              child: path == null
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.backgroundElevation1Alt,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 84.w,
                        height: 84.w,
                        child: Center(
                          child: Assets.icons.icUser.svg(
                            width: 28.w,
                            height: 28.w,
                            colorFilter: ColorFilter.mode(
                              colors.iconSub,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Image.file(
                      File(path!),
                      width: 84.w,
                      height: 84.w,
                      fit: BoxFit.cover,
                    ),
            ),
            SizedBox(height: 6.h),
            l10n.userCreateAvatarUpload.s(12.sp).w(600).c(colors.textSub),
          ],
        ),
      ),
    );
  }
}

class _PassportFields extends StatelessWidget {
  const _PassportFields({required this.series, required this.number});

  final TextEditingController series;
  final TextEditingController number;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(l10n.userDetailPassport),
        Row(
          children: [
            SizedBox(
              width: 82.w,
              child: AppEditableField(
                label: l10n.userDetailPassport,
                showLabel: false,
                controller: series,
                hintText: 'AA',
                textInputAction: TextInputAction.next,
                maxLength: 2,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
                  _UpperCaseFormatter(),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: AppEditableField(
                label: l10n.userDetailPassport,
                showLabel: false,
                controller: number,
                hintText: '1234567',
                keyboardType: TextInputType.number,
                maxLength: 7,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilePickerField extends StatelessWidget {
  const _FilePickerField({
    required this.label,
    required this.path,
    required this.onTap,
  });

  final String label;
  final String? path;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final name = path?.split(RegExp(r'[/\\]')).last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: appFilterFieldDecoration(colors),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SizedBox(
                height: 44.h,
                child: Row(
                  children: [
                    Assets.icons.icAddFile.svg(
                      width: 18.w,
                      height: 18.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: (name ?? l10n.userCreateImageUpload)
                          .s(13.sp)
                          .w(500)
                          .c(name == null ? colors.textSub : colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

Future<T?> _showPicker<T>(
  BuildContext context, {
  required String title,
  required List<T> values,
  required String Function(T value) label,
}) {
  final colors = AppColors.of(context);
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    backgroundColor: colors.backgroundBase,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title.s(17.sp).w(800).c(colors.textStrong),
            SizedBox(height: 12.h),
            Flexible(
              child: values.isEmpty
                  ? Center(
                      child: l10n.statEmpty.s(13.sp).w(500).c(colors.textSub),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: values.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: colors.strokeSoft, height: 1.h),
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => Navigator.of(context).pop(values[index]),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: label(values[index])
                              .s(14.sp)
                              .w(600)
                              .c(colors.textStrong)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
