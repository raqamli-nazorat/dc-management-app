import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bloc/session_bloc.dart';

/// Gate shown to authenticated users who have not yet completed today's
/// attendance. The router keeps the user here until [SessionAttendanceCompleted]
/// flips the flag, then routes to home.
///
/// TODO: replace the demo button with the real attendance/check-in flow.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Complete attendance to continue'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<SessionBloc>()
                  .add(const SessionAttendanceCompleted()),
              child: const Text('Mark attendance'),
            ),
            TextButton(
              onPressed: () =>
                  context.read<SessionBloc>().add(const SessionLogoutRequested()),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
