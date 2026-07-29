import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/bloc/session_bloc.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';
import '../../../../../core/services/biometric_auth_service.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../bloc/pin_bloc.dart';
import '../widgets/pin_indicator.dart';
import '../widgets/pin_keypad.dart';

/// PIN avtorizatsiya ekrani. Har ilova ochilishida ko‘rsatiladi: keshlangan
/// login + terilgan PIN (parol) bilan Login API’ga so‘rov yuboradi.
class PinPage extends StatelessWidget {
  const PinPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PinBloc>(
      create: (_) =>
          getIt<PinBloc>()..add(const PinBiometricAvailabilityChecked()),
      child: const _PinView(),
    );
  }
}

class _PinView extends StatefulWidget {
  const _PinView();

  @override
  State<_PinView> createState() => _PinViewState();
}

class _PinViewState extends State<_PinView> {
  bool _autoBiometricPromptRequested = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: BlocListener<PinBloc, PinState>(
        listenWhen: (p, c) =>
            p.status != c.status ||
            p.biometricResult != c.biometricResult ||
            p.biometricAvailability != c.biometricAvailability,
        listener: (context, state) {
          if (!_autoBiometricPromptRequested &&
              state.biometricAvailability == BiometricAvailability.available &&
              !state.biometricPromptInProgress &&
              state.pin.isEmpty &&
              !state.isBusy &&
              !state.isBlocked) {
            _autoBiometricPromptRequested = true;
            context.read<PinBloc>().add(
              PinBiometricRequested(l10n.biometricPromptReason),
            );
          }
          if (state.status == PinStatus.success && state.token != null) {
            context.read<SessionBloc>().add(
              SessionLoggedIn(token: state.token!, roles: state.roles),
            );
          }
          if (state.biometricResult == BiometricAuthResult.success) {
            context.read<SessionBloc>().add(const SessionBiometricUnlocked());
          }
        },
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 72.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: l10n.pinTitle
                          .s(28.sp)
                          .w(800)
                          .c(colors.textStrong)
                          .h(32 / 28)
                          .copyWith(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    Tooltip(
                      message: l10n.profileLogoutConfirm,
                      child: IconButton(
                        onPressed: () => context.read<SessionBloc>().add(
                          const SessionLogoutRequested(),
                        ),
                        icon: Assets.icons.icArrowRightExit.svg(
                          width: 28.r,
                          height: 28.r,
                          colorFilter: ColorFilter.mode(
                            colors.errorStrong,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                l10n.pinSubtitle
                    .s(15.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .h(24 / 15)
                    .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              BlocBuilder<PinBloc, PinState>(
                                buildWhen: (p, c) =>
                                    p.pin != c.pin ||
                                    p.obscure != c.obscure ||
                                    p.status != c.status ||
                                    p.length != c.length,
                                builder: (context, state) {
                                  return PinIndicator(
                                    length: state.length,
                                    pin: state.pin,
                                    obscure: state.obscure,
                                    status: state.status,
                                    onToggleVisibility: () => context
                                        .read<PinBloc>()
                                        .add(const PinVisibilityToggled()),
                                  );
                                },
                              ),
                              SizedBox(height: 12.h),
                              const _PinStatusMessage(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                BlocBuilder<PinBloc, PinState>(
                  buildWhen: (p, c) =>
                      p.status != c.status ||
                      p.biometricAvailability != c.biometricAvailability ||
                      p.biometricPromptInProgress !=
                          c.biometricPromptInProgress,
                  builder: (context, state) {
                    final bloc = context.read<PinBloc>();
                    return PinKeypad(
                      enabled:
                          !state.isBusy &&
                          !state.isBlocked &&
                          !state.biometricPromptInProgress,
                      onDigit: (d) => bloc.add(PinDigitPressed(d)),
                      onBackspace: () => bloc.add(const PinBackspacePressed()),
                      biometricAvailable:
                          state.biometricAvailability ==
                          BiometricAvailability.available,
                      onBiometric: () => bloc.add(
                        PinBiometricRequested(l10n.biometricPromptReason),
                      ),
                    );
                  },
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Xato / bloklash holatidagi ikki qatorli matn (Figma: error-sub 15/24 +
/// error-soft 13/20). Bloklashda ikkinchi qator MM:SS sanоqni ko‘rsatadi.
class _PinStatusMessage extends StatelessWidget {
  const _PinStatusMessage();

  String _formatCountdown(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<PinBloc, PinState>(
      buildWhen: (p, c) =>
          p.error != c.error || p.blockedSeconds != c.blockedSeconds,
      builder: (context, state) {
        final (String? primary, String? secondary) = switch (state.error) {
          PinError.incorrect => (l10n.pinIncorrect, l10n.pinRetry),
          PinError.blocked => (
            l10n.pinBlocked,
            l10n.pinBlockedRetryIn(_formatCountdown(state.blockedSeconds)),
          ),
          PinError.network => (l10n.networkError, null),
          PinError.biometricLocked => (
            l10n.biometricLocked,
            l10n.biometricTryPin,
          ),
          PinError.biometricUnavailable => (
            l10n.biometricNotAvailable,
            l10n.biometricTryPin,
          ),
          PinError.generic => (l10n.commonError, null),
          PinError.none => (null, null),
        };

        if (primary == null) return SizedBox(height: 44.h);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            primary
                .s(15.sp)
                .w(500)
                .c(colors.errorSub)
                .h(24 / 15)
                .a(TextAlign.center)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            if (secondary != null)
              secondary
                  .s(13.sp)
                  .w(500)
                  .c(colors.errorSoft)
                  .h(20 / 13)
                  .a(TextAlign.center)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        );
      },
    );
  }
}
