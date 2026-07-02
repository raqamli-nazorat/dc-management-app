import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notification.dart';
import '../bloc/notification_bloc.dart';
import '../widgets/notification_detail_sheet.dart';
import '../widgets/notification_tile.dart';

/// Bildirishnomalar ekrani (design: `Bildirishnomalar`).
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationBloc>(
      create: (_) =>
          getIt<NotificationBloc>()..add(const NotificationsRequested()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatelessWidget {
  const _NotificationView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      appBar: AppBar(
        backgroundColor: colors.backgroundBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Assets.icons.icArrowLeftBold.svg(
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
          ),
        ),
        title: l10n.notificationsTitle.s(17.sp).w(700).c(colors.textStrong),
        actions: [
          IconButton(
            tooltip: l10n.notificationMarkAllRead,
            onPressed: () => context
                .read<NotificationBloc>()
                .add(const NotificationReadAllRequested()),
            // Dizaynda `tick-double` — mos SVG asset yo‘q, shu bois material
            // `done_all` amal ikonkasi ishlatiladi (accent rangda).
            icon: Icon(Icons.done_all, size: 22.w, color: colors.iconAccent),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          switch (state.status) {
            case NotificationStatus.loading:
            case NotificationStatus.initial:
              return const Center(child: CircularProgressIndicator());
            case NotificationStatus.failure:
              return _ErrorState(
                onRetry: () => context
                    .read<NotificationBloc>()
                    .add(const NotificationsRequested()),
              );
            case NotificationStatus.success:
              if (state.items.isEmpty) {
                return Center(
                  child: l10n.notificationsEmpty
                      .s(14.sp)
                      .w(500)
                      .c(colors.textSub),
                );
              }
              return _NotificationList(items: state.items);
          }
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});

  final List<NotificationEntity> items;

  /// Sanaga qarab guruhlaydi (createdAt kuni bo‘yicha), tartib saqlanadi.
  Map<String, List<NotificationEntity>> _grouped() {
    final map = <String, List<NotificationEntity>>{};
    for (final n in items) {
      final d = n.createdAt;
      final key = d == null
          ? ''
          : '${_pad(d.day)}.${_pad(d.month)}.${d.year}';
      map.putIfAbsent(key, () => []).add(n);
    }
    return map;
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final groups = _grouped();

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      children: [
        for (final entry in groups.entries) ...[
          if (entry.key.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h, top: 8.h),
              child: entry.key.s(13.sp).w(600).c(colors.textSoft),
            ),
          for (final n in entry.value)
            NotificationTile(
              notification: n,
              onTap: () {
                if (!n.isRead) {
                  context
                      .read<NotificationBloc>()
                      .add(NotificationMarkedRead(n.id));
                }
                NotificationDetailSheet.show(context, n);
              },
            ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          l10n.commonError.s(14.sp).w(500).c(colors.textSub).a(TextAlign.center),
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
