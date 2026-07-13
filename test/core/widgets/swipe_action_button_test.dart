import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/config/theme/app_theme.dart';
import 'package:dc_management_app/core/widgets/swipe_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget app({
    required String label,
    required bool handleOnRight,
    required VoidCallback onCompleted,
  }) => ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 350,
            child: Builder(
              builder: (context) {
                final colors = AppColors.of(context);
                return SwipeActionButton(
                  label: label,
                  onCompleted: onCompleted,
                  trackColor: colors.backgroundElevation1Alt,
                  handleColor: colors.accentStrong,
                  handleOnRight: handleOnRight,
                  resetAfterComplete: false,
                  icon: const SizedBox.shrink(),
                );
              },
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('calls completion only after a full left-to-right swipe', (
    tester,
  ) async {
    var completions = 0;
    await tester.pumpWidget(
      app(
        label: 'Checked',
        handleOnRight: false,
        onCompleted: () => completions++,
      ),
    );

    final button = find.byType(SwipeActionButton);
    var gesture = await tester.startGesture(
      tester.getTopLeft(button) + const Offset(24, 26),
    );
    await gesture.moveBy(const Offset(80, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(completions, 0);

    gesture = await tester.startGesture(
      tester.getTopLeft(button) + const Offset(24, 26),
    );
    await gesture.moveBy(const Offset(320, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(completions, 1);
  });

  testWidgets('right handle completes only when swiped left', (tester) async {
    var completions = 0;
    await tester.pumpWidget(
      app(
        label: 'Rejected',
        handleOnRight: true,
        onCompleted: () => completions++,
      ),
    );

    final button = find.byType(SwipeActionButton);
    final start = tester.getTopRight(button) - const Offset(24, -26);
    final gesture = await tester.startGesture(start);
    await gesture.moveBy(const Offset(-320, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(completions, 1);
  });
}
