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
      body: RefreshIndicator(
        color: colors.accentSub,
        onRefresh: () => _onRefresh(context),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            switch (state.status) {
              case NotificationStatus.loading:
              case NotificationStatus.initial:
                return const _CenteredScrollable(
                  child: CircularProgressIndicator(),
                );
              case NotificationStatus.failure:
                return _CenteredScrollable(
                  child: _ErrorState(
                    onRetry: () => context
                        .read<NotificationBloc>()
                        .add(const NotificationsRequested()),
                  ),
                );
              case NotificationStatus.success:
                if (state.items.isEmpty) {
                  return _CenteredScrollable(
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
      ),
    );
  }

  /// Bildirishnomalarni qayta yuklaydi va `loading`dan chiqquncha kutadi —
  /// `RefreshIndicator` shu Future tugaguncha aylanadi.
  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<NotificationBloc>();
    bloc.add(const NotificationsRequested());
    return bloc.stream
        .firstWhere((s) => s.status != NotificationStatus.loading);
  }
}

/// Ro‘yxat bo‘lmagan holatlar (yuklanish/xato/bo‘sh) uchun — `RefreshIndicator`
/// ishlashi uchun har doim aylantirish mumkin bo‘lgan konteyner.
class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(child: child),
          ),
        ],
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
      physics: const AlwaysScrollableScrollPhysics(),
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
