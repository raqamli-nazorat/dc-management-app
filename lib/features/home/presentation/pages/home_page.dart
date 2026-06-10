import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bloc/session_bloc.dart';

/// Authenticated landing screen. Reached only when the session is valid and
/// today's attendance is complete.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<SessionBloc>().add(const SessionLogoutRequested()),
          ),
        ],
      ),
      body: const Center(child: Text('Welcome')),
    );
  }
}
