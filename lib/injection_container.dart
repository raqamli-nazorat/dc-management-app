import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'app/bloc/session_bloc.dart';
import 'config/routes/coordinator.dart';
import 'core/constants/storage_keys.dart';
import 'core/network/dio_client.dart';
import 'core/network/dio_factory.dart';
import 'core/network/interceptors/auth_interceptor.dart';
import 'core/network/interceptors/logging_interceptor.dart';
import 'core/network/interceptors/refresh_interceptor.dart';
import 'core/services/logger_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/token_service.dart';
import 'features/auth/data/data_sources/auth_remote_data_source.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/pin/bloc/pin_bloc.dart';
import 'features/auth/presentation/role/bloc/role_select_bloc.dart';
import 'features/meetings/data/data_sources/meeting_remote_data_source.dart';
import 'features/meetings/data/repository/meeting_repository_impl.dart';
import 'features/meetings/domain/repository/meeting_repository.dart';
import 'features/meetings/domain/usecases/get_meeting_attendance_usecase.dart';
import 'features/meetings/domain/usecases/get_meeting_usecase.dart';
import 'features/meetings/domain/usecases/get_meetings_usecase.dart';
import 'features/meetings/domain/usecases/submit_absence_reason_usecase.dart';
import 'features/meetings/presentation/bloc/meeting_reason_bloc.dart';
import 'features/meetings/presentation/bloc/meetings_bloc.dart';
import 'features/tasks/data/data_sources/task_remote_data_source.dart';
import 'features/tasks/data/repository/task_repository_impl.dart';
import 'features/tasks/domain/repository/task_repository.dart';
import 'features/tasks/domain/usecases/get_project_members_usecase.dart';
import 'features/tasks/domain/usecases/get_task_form_options_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/submit_task_usecase.dart';
import 'features/tasks/presentation/bloc/task_create_bloc.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';
import 'features/notification/data/data_sources/notification_remote_data_source.dart';
import 'features/notification/data/data_sources/notification_socket_service.dart';
import 'features/notification/data/repository/notification_repository_impl.dart';
import 'features/notification/domain/repository/notification_repository.dart';
import 'features/notification/domain/usecases/notification_usecases.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/profile/data/data_sources/profile_remote_data_source.dart';
import 'features/profile/data/repository/profile_repository_impl.dart';
import 'features/profile/domain/repository/profile_repository.dart';
import 'features/profile/domain/usecases/change_password_usecase.dart';
import 'features/profile/domain/usecases/get_me_usecase.dart';
import 'features/profile/domain/usecases/update_me_usecase.dart';
import 'features/profile/presentation/bloc/change_password_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/statistics/data/data_sources/statistics_remote_data_source.dart';
import 'features/statistics/data/repository/statistics_repository_impl.dart';
import 'features/statistics/domain/repository/statistics_repository.dart';
import 'features/statistics/domain/usecases/get_efficiency_usecase.dart';
import 'features/statistics/domain/usecases/get_period_statistics_usecase.dart';
import 'features/statistics/presentation/bloc/statistics_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core services ─────────────────────────────────────────────────────
  final storage = await StorageService.persistent(allowList: StorageKeys.all);
  getIt
    ..registerSingleton<StorageService>(storage)
    ..registerLazySingleton<LoggerService>(() => LoggerService())
    ..registerLazySingleton<TokenService>(() => TokenService(getIt()))
    ..registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(getIt(), getIt()),
    );

  // Session (drives navigation) — singleton so router + UI share one instance.
  getIt.registerLazySingleton<SessionBloc>(
    () => SessionBloc(tokenService: getIt(), storage: getIt()),
  );

  // ── Network ───────────────────────────────────────────────────────────
  // `Dio` alohida ro‘yxatga olinadi — Thunder debug overlay’i uni to‘g‘ridan
  // to‘g‘ri kuzatishi uchun (`getIt<Dio>()`).
  getIt.registerLazySingleton<Dio>(() {
    final dio = DioFactory.create();
    // Refresh + retry uchun alohida (interceptorsiz) Dio — sikldan saqlaydi.
    final refreshDio = DioFactory.create();
    dio.interceptors.addAll([
      AuthInterceptor(getIt<TokenService>()),
      RefreshInterceptor(
        tokenService: getIt<TokenService>(),
        refreshDio: refreshDio,
        session: () => getIt<SessionBloc>(),
      ),
      LoggingInterceptor(getIt<LoggerService>()),
    ]);
    return dio;
  });
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt<Dio>()));

  // ── Auth feature ──────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remote: getIt(),
        tokenService: getIt(),
        storage: getIt(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()))
    ..registerFactory<LoginBloc>(() => LoginBloc(loginUseCase: getIt()))
    ..registerFactory<PinBloc>(
      () => PinBloc(loginUseCase: getIt(), storage: getIt()),
    )
    // `UpdateMeUseCase` Profile bo‘limida ro‘yxatga olinadi — lazy factory
    // bo‘lgani uchun chaqiruv vaqtida (getIt<RoleSelectBloc>()) hal bo‘ladi.
    ..registerFactory<RoleSelectBloc>(
      () => RoleSelectBloc(updateMe: getIt()),
    );

  // ── Profile feature ───────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetMeUseCase>(() => GetMeUseCase(getIt()))
    ..registerLazySingleton<UpdateMeUseCase>(() => UpdateMeUseCase(getIt()))
    ..registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt()),
    )
    ..registerFactory<ProfileBloc>(() => ProfileBloc(getMe: getIt()))
    ..registerFactory<ChangePasswordBloc>(
      () => ChangePasswordBloc(changePassword: getIt(), storage: getIt()),
    );

  // ── Meetings feature ──────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<MeetingRemoteDataSource>(
      () => MeetingRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<MeetingRepository>(
      () => MeetingRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetMeetingsUseCase>(
      () => GetMeetingsUseCase(getIt()),
    )
    ..registerLazySingleton<GetMeetingUseCase>(() => GetMeetingUseCase(getIt()))
    ..registerLazySingleton<GetMeetingAttendanceUseCase>(
      () => GetMeetingAttendanceUseCase(getIt()),
    )
    ..registerLazySingleton<SubmitAbsenceReasonUseCase>(
      () => SubmitAbsenceReasonUseCase(getIt()),
    )
    ..registerFactory<MeetingsBloc>(() => MeetingsBloc(getMeetings: getIt()))
    ..registerFactory<MeetingReasonBloc>(
      () => MeetingReasonBloc(
        getMeeting: getIt(),
        getAttendance: getIt(),
        submitReason: getIt(),
      ),
    );

  // ── Tasks feature ─────────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(getIt()))
    ..registerLazySingleton<GetTasksUseCase>(() => GetTasksUseCase(getIt()))
    ..registerLazySingleton<GetTaskFormOptionsUseCase>(
      () => GetTaskFormOptionsUseCase(getIt()),
    )
    ..registerLazySingleton<GetProjectMembersUseCase>(
      () => GetProjectMembersUseCase(getIt()),
    )
    ..registerLazySingleton<SubmitTaskUseCase>(() => SubmitTaskUseCase(getIt()))
    ..registerFactory<TasksBloc>(() => TasksBloc(getTasks: getIt()))
    ..registerFactory<TaskCreateBloc>(
      () => TaskCreateBloc(
        getOptions: getIt(),
        getMembers: getIt(),
        submitTask: getIt(),
      ),
    );

  // ── Statistics feature ────────────────────────────────────────────────
  getIt
    ..registerLazySingleton<StatisticsRemoteDataSource>(
      () => StatisticsRemoteDataSourceImpl(getIt()),
    )
    ..registerLazySingleton<StatisticsRepository>(
      () => StatisticsRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<GetPeriodStatisticsUseCase>(
      () => GetPeriodStatisticsUseCase(getIt()),
    )
    ..registerLazySingleton<GetEfficiencyUseCase>(
      () => GetEfficiencyUseCase(getIt()),
    )
    ..registerFactory<StatisticsBloc>(
      () => StatisticsBloc(getPeriod: getIt(), getEfficiency: getIt()),
    );

  // ── Notification feature ──────────────────────────────────────────────
  getIt
    ..registerLazySingleton<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(getIt()),
    )
    // WebSocket real-vaqt oqimi — datasource orqali ticket oladi (repo’ga
    // bog‘liq emas, sikldan xoli). Singleton — app bo‘yicha yagona ulanish.
    ..registerLazySingleton<NotificationSocketService>(
      () => NotificationSocketService(remote: getIt(), logger: getIt()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(getIt(), getIt()),
    )
    ..registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<WatchNotificationsUseCase>(
      () => WatchNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(getIt()),
    )
    ..registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(getIt()),
    )
    ..registerLazySingleton<ReadAllNotificationsUseCase>(
      () => ReadAllNotificationsUseCase(getIt()),
    )
    ..registerLazySingleton<RegisterDeviceUseCase>(
      () => RegisterDeviceUseCase(getIt()),
    )
    ..registerFactory<NotificationBloc>(
      () => NotificationBloc(
        getNotifications: getIt(),
        markRead: getIt(),
        readAll: getIt(),
        watch: getIt(),
      ),
    );

  // ── Router — built once from the session cubit. ─────────────────────────
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(getIt<SessionBloc>()));
}
