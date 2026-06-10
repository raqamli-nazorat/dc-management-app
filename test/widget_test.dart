import 'package:dc_management_app/app/app.dart';
import 'package:dc_management_app/app/bloc/session_bloc.dart';
import 'package:dc_management_app/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
    final session = getIt<SessionBloc>()..add(const SessionStarted());
    await session.stream.firstWhere((state) => state.isResolved);
  });

  testWidgets('routes to login when no session exists', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Kirish'), findsWidgets);
  });
}
