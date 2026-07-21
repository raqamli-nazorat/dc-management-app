import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/contact_input_formatters.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_file_actions.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../domain/entities/app_user.dart';
import '../bloc/user_detail_bloc.dart';

/// Foydalanuvchi detail sahifasi (`Routes.userDetail`, `GET /users/{id}/`) —
/// Figma "Foydalanuvchining ma'lumotlari": faqat o'qish uchun boxed maydonlar.
class UserDetailPage extends StatelessWidget {
  const UserDetailPage({required this.userId, super.key});

  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserDetailBloc>(
      create: (_) => getIt<UserDetailBloc>()..add(UserDetailRequested(userId)),
      child: _UserDetailView(userId: userId),
    );
  }
}

class _UserDetailView extends StatelessWidget {
  const _UserDetailView({required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            AppFilterHeader(title: l10n.userDetailTitle),
            Expanded(
              child: BlocBuilder<UserDetailBloc, UserDetailState>(
                builder: (context, state) {
                  switch (state.status) {
                    case UserDetailStatus.loading:
                    case UserDetailStatus.initial:
                      return const Center(child: CircularProgressIndicator());
                    case UserDetailStatus.failure:
                      return _ErrorState(
                        failure: state.failure,
                        onRetry: () => context.read<UserDetailBloc>().add(
                          UserDetailRequested(userId),
                        ),
                      );
                    case UserDetailStatus.success:
                      return _UserDetailBody(user: state.user!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserDetailBody extends StatelessWidget {
  const _UserDetailBody({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final roles = user.roles
        .map((r) => RolePresentation.of(l10n, r).label)
        .join(', ');
    // `passport_series` bitta string — harfli prefiks (seriya) va qolgan
    // qismi (raqam) alohida boxlarda ko'rsatiladi.
    final passportMatch = RegExp(
      r'^([A-Za-z]*)\s*(.*)$',
    ).firstMatch(user.passportSeries.trim());
    final passportLetters = passportMatch?.group(1) ?? '';
    final passportDigits = passportMatch?.group(2) ?? '';

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          Center(
            child: TuiAvatar(
              initial: user.username,
              avatarUrl: user.avatar,
              size: 84,
            ),
          ),
          _ReadonlyField(label: l10n.userDetailFullName, value: user.username),
          _ReadonlyField(
            label: l10n.userDetailCreatedAt,
            value: user.dateJoined == null
                ? ''
                : DateFormat('dd.MM.yyyy  HH:mm').format(user.dateJoined!),
          ),
          Row(
            spacing: 12.w,
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailPhone,
                  value: formatPhoneNumber(user.phoneNumber),
                ),
              ),
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailCard,
                  value: formatCardNumber(user.cardNumber),
                ),
              ),
            ],
          ),
          Row(
            spacing: 12.w,
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailSalary,
                  value: Formatters.formatAmountComma(user.fixedSalary),
                ),
              ),
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailBalance,
                  value: Formatters.formatAmountComma(user.balance),
                ),
              ),
            ],
          ),
          Row(
            spacing: 12.w,
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: l10n.reportFilterRegion,
                  value: user.regionName,
                  chevron: true,
                ),
              ),
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailDistrict,
                  value: user.districtName,
                  chevron: true,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFilterFieldLabel(l10n.userDetailPassport),
              Row(
                spacing: 8.w,
                children: [
                  SizedBox(
                    width: 60.w,
                    child: _ValueBox(value: passportLetters, centered: true),
                  ),
                  Expanded(child: _ValueBox(value: passportDigits)),
                ],
              ),
            ],
          ),
          if (user.passportImage.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppFilterFieldLabel(l10n.userDetailPassportImage),
                _PassportFileBox(url: user.passportImage),
              ],
            ),
          SizedBox(height: 4.h),
          _StatusRow(
            dotColor: colors.successPrimary,
            label: l10n.userDetailPosition,
            value: user.positionName,
          ),
          _StatusRow(
            dotColor: colors.errorSub,
            label: l10n.userDetailRole,
            value: roles,
          ),
        ],
      ),
    );
  }
}

/// Yorliq + faqat o'qish uchun boxed qiymat (filtr maydonlari ko'rinishi).
class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({
    required this.label,
    required this.value,
    this.chevron = false,
  });

  final String label;
  final String value;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        _ValueBox(value: value, chevron: chevron),
      ],
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({
    required this.value,
    this.chevron = false,
    this.centered = false,
  });

  final String value;
  final bool chevron;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final text = value
        .s(13.sp)
        .w(500)
        .h(20 / 13)
        .c(colors.textStrong)
        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: centered
              ? Center(child: text)
              : Row(
                  children: [
                    Expanded(child: text),
                    if (chevron) ...[
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
  }
}

/// Passport fayli: hujjat ikonkasi + fayl nomi + ochish/yuklab olish.
class _PassportFileBox extends StatelessWidget {
  const _PassportFileBox({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final segments = Uri.tryParse(url)?.pathSegments ?? const [];
    final name = segments.isEmpty ? url : Uri.decodeComponent(segments.last);

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
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
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: name
                    .s(13.sp)
                    .w(700)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8.w),
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
    );
  }
}

/// Pastki qator: rangli nuqta + yorliq + qiymatli pill (faqat o'qish uchun).
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.dotColor,
    required this.label,
    required this.value,
  });

  final Color dotColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
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
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8.w, height: 8.w),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: label
              .s(14.sp)
              .w(700)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 8.w),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: SizedBox(
              height: 32.h,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: (value.isEmpty ? '—' : value)
                        .s(13.sp)
                        .w(600)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final message = failure is NetworkFailure
        ? l10n.networkError
        : l10n.commonError;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          message.s(14.sp).w(500).c(colors.textSub).a(TextAlign.center),
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
