import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../app/bloc/session_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/login_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginBloc>().add(const LoginSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<LoginBloc, LoginState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: (context, state) {
          if (state.status == LoginStatus.success &&
              state.accessToken != null) {
            // Navigatsiya yagona manba — SessionBloc orqali.
            context.read<SessionBloc>().add(
                  SessionLoggedIn(
                    token: state.accessToken!,
                    roles: state.roles,
                  ),
                );
          }
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.authBackgroundGradient,
          ),
          child: Stack(
            children: [
              // ── Noise / shum qatlami ──────────────────────────────────
              Positioned.fill(
                child: IgnorePointer(
                  child: Image(
                    image: Assets.images.cardboardTexture.provider(),
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                    opacity: const AlwaysStoppedAnimation<double>(0.06),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Header(),
                            SizedBox(height: 40.h),
                            _LoginCard(
                              colors: colors,
                              formKey: _formKey,
                              loginController: _loginController,
                              passwordController: _passwordController,
                              onSubmit: _submit,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sahifa tepasidagi sarlavha + tavsif bloki (gradient ustida).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'Raqamli boshqaruv tizimiga xush kelibsiz'
            .s(24.sp)
            .w(800)
            .c(AppColors.authForeground)
            .h(28 / 24)
            .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        SizedBox(height: 8.h),
        'Loyihalar, vazifalar va moliyani bitta platformada boshqaring'
            .s(15.sp)
            .w(500)
            .c(AppColors.authForeground)
            .h(24 / 15)
            .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

/// "Kirish" formasi joylashgan karta.
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.colors,
    required this.formKey,
    required this.loginController,
    required this.passwordController,
    required this.onSubmit,
  });

  final AppColors colors;
  final GlobalKey<FormState> formKey;
  final TextEditingController loginController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colors.strokeSub),
        boxShadow: [
          BoxShadow(
            color: colors.black.withValues(alpha: 0.12),
            offset: Offset(0, 4.h),
            blurRadius: 24.r,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _LogoAndTitle(colors: colors),
            SizedBox(height: 20.h),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  'Kirish'.s(28.sp).w(800).c(colors.textStrong).h(32 / 28),
                  SizedBox(height: 16.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextField(
                        controller: loginController,
                        hintText: 'Login',
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onChanged: (v) => bloc.add(LoginUsernameChanged(v)),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Login kiriting'
                            : null,
                      ),
                      SizedBox(height: 8.h),
                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Parol',
                        obscureText: true,
                        showObscureToggle: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => bloc.add(LoginPasswordChanged(v)),
                        onSubmitted: (_) => onSubmit(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Parol kiriting'
                            : null,
                      ),
                      // ── Server xato matni (login/parol noto‘g‘ri, 429, ...) ──
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (p, c) =>
                            p.status != c.status ||
                            p.errorMessage != c.errorMessage,
                        builder: (context, state) {
                          if (state.status != LoginStatus.failure ||
                              state.errorMessage == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: state.errorMessage!
                                .s(13.sp)
                                .w(500)
                                .c(colors.errorSub)
                                .h(20 / 13)
                                .copyWith(
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  BlocBuilder<LoginBloc, LoginState>(
                    buildWhen: (p, c) =>
                        p.canSubmit != c.canSubmit || p.isLoading != c.isLoading,
                    builder: (context, state) {
                      return CustomButton(
                        label: 'Kirish',
                        enabled: state.canSubmit,
                        isLoading: state.isLoading,
                        onPressed: onSubmit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Karta tepasidagi logotip va brend nomi.
class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 32.r,
          height: 32.r,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.accentSub,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'R',
                style: GoogleFonts.unbounded(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  height: 24 / 20,
                  color: colors.textWhite,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: 'Raqamli Nazorat'
              .s(15.sp)
              .w(500)
              .c(colors.textStrong)
              .h(24 / 15)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
