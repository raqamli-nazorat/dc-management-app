import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Ilova dizaynidagi kalendar (Figma "Datepicker") — `showDatePicker` o'rniga.
/// Kun bosilganda tanlangan [DateTime] bilan yopiladi (tasdiq tugmasi yo'q).
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: _AppCalendar(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    ),
  );
}

/// Oy nomlari (o'zbekcha) — 1..12.
const _months = [
  'Yanvar',
  'Fevral',
  'Mart',
  'Aprel',
  'May',
  'Iyun',
  'Iyul',
  'Avgust',
  'Sentyabr',
  'Oktyabr',
  'Noyabr',
  'Dekabr',
];

/// Hafta kunlari qisqartmasi (dushanbadan boshlab).
const _weekdays = ['Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Yak'];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _AppCalendar extends StatefulWidget {
  const _AppCalendar({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<_AppCalendar> {
  late DateTime _visible = DateTime(
    widget.initialDate.year,
    widget.initialDate.month,
  );
  late final DateTime _first = _dateOnly(widget.firstDate);
  late final DateTime _last = _dateOnly(widget.lastDate);

  bool get _canPrev =>
      DateTime(_visible.year, _visible.month).isAfter(
        DateTime(_first.year, _first.month),
      );
  bool get _canNext =>
      DateTime(_visible.year, _visible.month).isBefore(
        DateTime(_last.year, _last.month),
      );

  void _shift(int months) =>
      setState(() => _visible = DateTime(_visible.year, _visible.month + months));

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
          bottom: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 24.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(colors),
            SizedBox(height: 8.h),
            _weekdayRow(colors),
            SizedBox(height: 2.h),
            ..._weekRows(colors),
          ],
        ),
      ),
    );
  }

  Widget _header(AppColors colors) {
    return Row(
      children: [
        _arrow(Assets.icons.icArrowLeftBold, colors, _canPrev ? () => _shift(-1) : null),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _months[_visible.month - 1].s(16.sp).w(800).c(colors.textStrong),
              SizedBox(width: 4.w),
              '${_visible.year}'.s(13.sp).w(800).c(colors.textSoft),
            ],
          ),
        ),
        _arrow(Assets.icons.icArrowRight, colors, _canNext ? () => _shift(1) : null),
      ],
    );
  }

  Widget _arrow(SvgGenImage icon, AppColors colors, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: icon.svg(
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(
            onTap == null ? colors.iconDisabled : colors.iconStrong,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  Widget _weekdayRow(AppColors colors) {
    return Row(
      children: [
        for (final w in _weekdays)
          Expanded(
            child: SizedBox(
              height: 32.h,
              child: Center(child: w.s(11.sp).w(500).c(colors.textSoft)),
            ),
          ),
      ],
    );
  }

  List<Widget> _weekRows(AppColors colors) {
    final firstOfMonth = DateTime(_visible.year, _visible.month, 1);
    // Dushanbadan boshlanadigan to'r: oy 1-kuni joylashgan hafta boshi.
    final start = firstOfMonth.subtract(
      Duration(days: firstOfMonth.weekday - 1),
    );

    return [
      for (var week = 0; week < 6; week++)
        Row(
          children: [
            for (var d = 0; d < 7; d++)
              Expanded(child: _dayCell(start.add(Duration(days: week * 7 + d)), colors)),
          ],
        ),
    ];
  }

  Widget _dayCell(DateTime date, AppColors colors) {
    final inMonth = date.month == _visible.month;
    final weekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    final outOfRange = date.isBefore(_first) || date.isAfter(_last);
    final selectable = inMonth && !outOfRange;
    final selected = _sameDay(date, widget.initialDate);
    final today = _sameDay(date, DateTime.now());

    final Color textColor;
    if (selected) {
      textColor = colors.textWhite;
    } else if (!inMonth || outOfRange) {
      textColor = colors.controlTextDisabled;
    } else if (weekend) {
      textColor = colors.textSoft;
    } else {
      textColor = colors.textStrong;
    }

    return InkWell(
      onTap: selectable ? () => Navigator.of(context).pop(date) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 34.h,
        child: Center(
          child: SizedBox(
            width: 32.w,
            height: 32.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? colors.accentStrong : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: today && !selected
                    ? Border.all(color: colors.strokeStrong, width: 1.w)
                    : null,
              ),
              child: Center(
                child: '${date.day}'.s(13.sp).w(500).c(textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
