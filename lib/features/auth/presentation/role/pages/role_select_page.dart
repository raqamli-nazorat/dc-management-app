import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/bloc/session_bloc.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../l10n/app_localizations.dart';
import '../role_presentation.dart';
import '../widgets/role_tile.dart';

/// Rol tanlash ekrani — bir nechta rol bo‘lganda. Rollar API javobidan
/// dinamik ro‘yxatlanadi.
class RoleSelectPage extends StatelessWidget {
  const RoleSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final roles = context.select<SessionBloc, List<String>>(
      (bloc) => bloc.state.roles,
    );

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              l10n.roleTitle
                  .s(28.sp)
                  .w(800)
                  .c(colors.textStrong)
                  .h(32 / 28)
                  .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
              SizedBox(height: 8.h),
              l10n.roleSubtitle
                  .s(15.sp)
                  .w(500)
                  .c(colors.textStrong)
                  .h(24 / 15)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < roles.length; i++) ...[
                          if (i > 0) SizedBox(height: 20.h),
                          Builder(
                            builder: (context) {
                              final presentation =
                                  RolePresentation.of(l10n, roles[i]);
                              return RoleTile(
                                label: presentation.label,
                                icon: presentation.icon,
                                onTap: () => context
                                    .read<SessionBloc>()
                                    .add(SessionRoleSelected(roles[i])),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
