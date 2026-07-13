import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/theme/app_colors.dart';
import '../gen/assets.gen.dart';
import 'app_toast.dart';

class AppFileActions extends StatelessWidget {
  const AppFileActions({
    required this.url,
    required this.openLabel,
    required this.downloadLabel,
    required this.errorTitle,
    super.key,
  });

  final String url;
  final String openLabel;
  final String downloadLabel;
  final String errorTitle;

  Future<void> _launch(BuildContext context, LaunchMode mode) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !const ['http', 'https'].contains(uri.scheme)) {
      if (context.mounted) AppToast.showError(context, title: errorTitle);
      return;
    }

    var launched = false;
    try {
      launched = await launchUrl(uri, mode: mode);
    } on Object {
      // url_launcher channel/device browser unavailable: UI crash qilmasin.
      launched = false;
    }

    if (!launched && context.mounted) {
      AppToast.showError(context, title: errorTitle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final uri = Uri.tryParse(url);
    final canLaunch =
        uri != null && const ['http', 'https'].contains(uri.scheme);

    Widget button(String label, SvgGenImage icon, LaunchMode mode) => Tooltip(
      message: label,
      child: InkWell(
        onTap: canLaunch ? () => _launch(context, mode) : null,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: icon.svg(
            width: 16.w,
            height: 16.w,
            colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          openLabel,
          Assets.icons.icEyeOpen,
          LaunchMode.externalApplication,
        ),
        SizedBox(width: 2.w),
        button(
          downloadLabel,
          Assets.icons.icDownload,
          LaunchMode.externalApplication,
        ),
      ],
    );
  }
}
