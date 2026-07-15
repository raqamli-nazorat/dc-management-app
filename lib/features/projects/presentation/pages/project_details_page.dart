import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/nav_permissions.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/project_details_bloc.dart';
import 'add_project_page.dart';

class ProjectDetailsPage extends StatelessWidget {
  const ProjectDetailsPage({
    required this.projectId,
    this.edit = false,
    super.key,
  });

  final int projectId;
  final bool edit;

  @override
  Widget build(BuildContext context) {
    final role = context.select<SessionBloc, RoleType>((b) => b.state.roleType);
    // Maydonlarni faqat admin tahrirlaydi; menejer `edit`ga kirsa — forma
    // qulf, hujjatlar bo'limi ochiq.
    final readOnly = !edit || !NavPermissions.canEditProjectFields(role);
    final docsOnly = edit && readOnly && NavPermissions.canManageProject(role);
    return BlocProvider<ProjectDetailsBloc>(
      create: (_) =>
          getIt<ProjectDetailsBloc>()..add(ProjectDetailsRequested(projectId)),
      child: _ProjectDetailsView(
        projectId: projectId,
        edit: edit,
        readOnly: readOnly,
        docsOnly: docsOnly,
      ),
    );
  }
}

class _ProjectDetailsView extends StatelessWidget {
  const _ProjectDetailsView({
    required this.projectId,
    required this.edit,
    required this.readOnly,
    required this.docsOnly,
  });

  final int projectId;
  final bool edit;
  final bool readOnly;
  final bool docsOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ProjectDetailsBloc, ProjectDetailsState>(
      builder: (context, state) {
        switch (state.status) {
          case ProjectDetailsStatus.initial:
          case ProjectDetailsStatus.loading:
            return Scaffold(
              backgroundColor: colors.backgroundBase,
              body: const Center(child: CircularProgressIndicator()),
            );
          case ProjectDetailsStatus.failure:
            return Scaffold(
              backgroundColor: colors.backgroundBase,
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        l10n.commonError
                            .s(14.sp)
                            .w(500)
                            .c(colors.textSub)
                            .a(TextAlign.center),
                        SizedBox(height: 12.h),
                        TextButton(
                          onPressed: () => context
                              .read<ProjectDetailsBloc>()
                              .add(ProjectDetailsRequested(projectId)),
                          child: l10n.commonRetry
                              .s(14.sp)
                              .w(700)
                              .c(colors.textAccent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          case ProjectDetailsStatus.success:
            final project = state.project;
            if (project == null) {
              AppToast.showError(context, title: l10n.commonError);
              return const SizedBox.shrink();
            }
            return AddProjectPage(
              project: project,
              readOnly: readOnly,
              docsOnly: docsOnly,
              screenTitle: edit
                  ? l10n.projectEditTitle
                  : l10n.projectDetailsTitle,
            );
        }
      },
    );
  }
}
