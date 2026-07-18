import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// To'lov chekini to'liq ekranda ko'rsatadi (Figma: "To'lov cheki" — qora
/// fon, tepada sarlavha + qizil yopish, markazda kattalashtiriladigan rasm).
Future<void> showReceiptViewer(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.9),
    builder: (_) => _ReceiptViewer(url: url),
  );
}

class _ReceiptViewer extends StatelessWidget {
  const _ReceiptViewer({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: l10n.expenseRequestReceiptViewerTitle
                        .s(17.sp)
                        .w(800)
                        .c(colors.textWhite)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 12.w),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(16.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.errorStrong,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(
                        width: 32.w,
                        height: 32.w,
                        child: Center(
                          child: Assets.icons.icClose.svg(
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
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null
                            ? child
                            : Center(
                                child: CircularProgressIndicator(
                                  color: colors.textWhite,
                                ),
                              ),
                        errorBuilder: (_, _, _) => Assets.icons.icDocument.svg(
                          width: 48.w,
                          height: 48.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconWhite,
                            BlendMode.srcIn,
                          ),
                        ),
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
}
