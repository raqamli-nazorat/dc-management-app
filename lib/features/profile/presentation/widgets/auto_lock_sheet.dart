import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

Future<Duration?> showAutoLockSheet(
  BuildContext context, {
  required Duration selected,
}) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<Duration>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.backgroundBase,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => _AutoLockSheet(selected: selected),
  );
}

String autoLockLabel(AppLocalizations l10n, Duration duration) =>
    switch (duration.inSeconds) {
      0 => l10n.securityAutoLockImmediately,
      60 => l10n.securityAutoLock1Minute,
      300 => l10n.securityAutoLock5Minutes,
      900 => l10n.securityAutoLock15Minutes,
      1800 => l10n.securityAutoLock30Minutes,
      3600 => l10n.securityAutoLock1Hour,
      _ => l10n.securityAutoLock1Hour,
    };

class _AutoLockSheet extends StatelessWidget {
  const _AutoLockSheet({required this.selected});

  final Duration selected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: l10n.securityAutoLock
                      .s(19.sp)
                      .w(800)
                      .c(colors.textStrong),
                ),
                SizedBox(height: 2.h),
                l10n.securityAutoLockSubtitle
                    .s(13.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 16.h),
                for (final timeout in SessionBloc.autoLockTimeouts) ...[
                  _AutoLockOption(
                    label: autoLockLabel(l10n, timeout),
                    selected: timeout == selected,
                    onTap: () => Navigator.of(context).pop(timeout),
                  ),
                  if (timeout != SessionBloc.autoLockTimeouts.last)
                    SizedBox(height: 8.h),
                ],
              ],
            ),
          ),
          Positioned(
            top: 8.h,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.strokeSub,
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: SizedBox(width: 24.w, height: 3.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoLockOption extends StatelessWidget {
  const _AutoLockOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(24.r);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? colors.backgroundElevation1Alt
              : colors.backgroundElevation1,
          borderRadius: radius,
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: label
                    .s(15.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (selected) ...[
                SizedBox(width: 8.w),
                Assets.icons.icCheckmarkCircle.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconAccent,
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
