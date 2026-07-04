import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// Logout confirmation dialog — asks user to confirm logout action.
/// Shows title, subtitle, and two buttons: "Orqaga" (cancel) and "Chiqish" (logout).
/// Uses theme tokens for colors and fl_screenutil for responsive sizing.
class LogoutConfirmDialog extends StatelessWidget {
  const LogoutConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: colors.backgroundBase,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag indicator
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.strokeSoft,
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: SizedBox(width: 24.w, height: 3.h),
              ),
            ),
            SizedBox(height: 24.h),
            // Title
            Center(
              child: l10n.profileLogoutTitle
                  .s(19.sp)
                  .w(800)
                  .c(colors.iconStrong)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: 4.h),
            // Subtitle
            Center(
              child: l10n.profileLogoutSubtitle
                  .s(13.sp)
                  .w(500)
                  .c(colors.textSub)
                  .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: 24.h),
            // Buttons row
            Row(
              children: [
                // Back button (secondary)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(16.r),
                        child: SizedBox(
                          height: 52.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.icons.icArrowLeftBold.svg(
                                width: 16.w,
                                height: 16.h,
                                colorFilter: ColorFilter.mode(
                                  colors.textStrong,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              l10n.profileLogoutBack
                                  .s(15.sp)
                                  .w(800)
                                  .c(colors.textStrong),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Logout button (danger/primary)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.errorStrong,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        onTap: () {
                          context
                              .read<SessionBloc>()
                              .add(const SessionLogoutRequested());
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: SizedBox(
                          height: 52.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Assets.icons.icTrash.svg(
                                width: 16.w,
                                height: 16.h,
                                colorFilter: ColorFilter.mode(
                                  colors.textWhite,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              l10n.profileLogoutConfirm
                                  .s(15.sp)
                                  .w(800)
                                  .c(colors.textWhite),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows logout confirmation dialog. Allows user to cancel or confirm logout.
Future<void> showLogoutConfirmDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: colors.black.withValues(alpha: 0.6),
    builder: (_) => const LogoutConfirmDialog(),
  );
}
