import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/theme/app_colors.dart';

/// Avatar nishoni holati.
enum TuiAvatarBadge {
  /// Nishon yo‘q.
  none,

  /// O‘qilgan — ko‘k doira ichida oq check.
  read,

  /// O‘qilmagan — to‘q sariq doira ichida oq son.
  unread,
}

/// `tui-avatar` — bosh harfli avatar + ixtiyoriy holat nishoni.
///
/// To‘liq [CustomPainter] bilan chiziladi (doira, harf, nishon) — shu sabab
/// hech qanday qatlamli `Stack`/`ClipOval` kerak emas va ixcham. Ranglar
/// tema tokenlaridan olinadi, shu bois light/dark ikkalasida ham to‘g‘ri
/// ko‘rinadi.
class TuiAvatar extends StatelessWidget {
  const TuiAvatar({
    super.key,
    required this.initial,
    this.badge = TuiAvatarBadge.none,
    this.count = 0,
    this.size = 32,
  });

  /// Ko‘rsatiladigan bosh harf (masalan ism/username birinchi harfi).
  final String initial;
  final TuiAvatarBadge badge;

  /// `unread` nishoni ustidagi son (0 bo‘lsa nuqta ko‘rsatiladi).
  final int count;

  /// Diametri (logik piksel, `.w` bilan skalanadi).
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final dimension = size.w;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: CustomPaint(
        painter: _TuiAvatarPainter(
          initial: initial.isNotEmpty ? initial.characters.first.toUpperCase() : '?',
          badge: badge,
          count: count,
          circleColor: colors.avatarPlaceholder,
          letterColor: colors.textSub,
          badgeReadColor: colors.badgeRead,
          badgeUnreadColor: colors.badgeUnread,
          ringColor: colors.backgroundBase,
          badgeTextColor: colors.textWhite,
        ),
      ),
    );
  }
}

class _TuiAvatarPainter extends CustomPainter {
  _TuiAvatarPainter({
    required this.initial,
    required this.badge,
    required this.count,
    required this.circleColor,
    required this.letterColor,
    required this.badgeReadColor,
    required this.badgeUnreadColor,
    required this.ringColor,
    required this.badgeTextColor,
  });

  final String initial;
  final TuiAvatarBadge badge;
  final int count;
  final Color circleColor;
  final Color letterColor;
  final Color badgeReadColor;
  final Color badgeUnreadColor;
  final Color ringColor;
  final Color badgeTextColor;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // ── Asosiy doira ──────────────────────────────────────────────────────
    canvas.drawCircle(center, radius, Paint()..color = circleColor);

    // ── Bosh harf ─────────────────────────────────────────────────────────
    _paintText(
      canvas,
      text: initial,
      color: letterColor,
      fontSize: size.width * 0.4,
      fontWeight: FontWeight.w700,
      center: center,
    );

    if (badge == TuiAvatarBadge.none) return;

    // ── Nishon ──────────────────────────────────────────────────────────
    final badgeRadius = size.width * 0.28;
    final badgeCenter = Offset(
      size.width - badgeRadius,
      size.height - badgeRadius,
    );
    // Fon rangidagi halqa — nishonni avatardan ajratadi.
    canvas.drawCircle(
      badgeCenter,
      badgeRadius + size.width * 0.06,
      Paint()..color = ringColor,
    );

    if (badge == TuiAvatarBadge.read) {
      canvas.drawCircle(badgeCenter, badgeRadius, Paint()..color = badgeReadColor);
      _paintCheck(canvas, badgeCenter, badgeRadius);
    } else {
      canvas.drawCircle(
        badgeCenter,
        badgeRadius,
        Paint()..color = badgeUnreadColor,
      );
      if (count > 0) {
        _paintText(
          canvas,
          text: count > 9 ? '9+' : '$count',
          color: badgeTextColor,
          fontSize: badgeRadius * 1.1,
          fontWeight: FontWeight.w700,
          center: badgeCenter,
        );
      }
    }
  }

  void _paintCheck(Canvas canvas, Offset c, double r) {
    final paint = Paint()
      ..color = badgeTextColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.28
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(c.dx - r * 0.45, c.dy + r * 0.02)
      ..lineTo(c.dx - r * 0.1, c.dy + r * 0.38)
      ..lineTo(c.dx + r * 0.5, c.dy - r * 0.35);
    canvas.drawPath(path, paint);
  }

  void _paintText(
    Canvas canvas, {
    required String text,
    required Color color,
    required double fontSize,
    required FontWeight fontWeight,
    required Offset center,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_TuiAvatarPainter old) =>
      old.initial != initial ||
      old.badge != badge ||
      old.count != count ||
      old.circleColor != circleColor ||
      old.letterColor != letterColor ||
      old.ringColor != ringColor;
}
