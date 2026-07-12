import 'package:flutter/material.dart';

import 'project_details_page.dart';

class EditProjectPage extends StatelessWidget {
  const EditProjectPage({required this.projectId, super.key});

  final int projectId;

  @override
  Widget build(BuildContext context) =>
      ProjectDetailsPage(projectId: projectId, edit: true);
}
