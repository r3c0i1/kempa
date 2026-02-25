import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kempa/core/network/token_manager.dart';
import 'package:kempa/core/theme/theme_block.dart';
import 'package:kempa/features/academic/data/datasources/academic_remote_datasource.dart';
import 'package:kempa/features/academic/data/repositories/academic_repository_impl.dart';
import 'package:kempa/features/academic/domain/repositories/academic_repository.dart';
import 'package:kempa/features/academic/domain/usecases/get_faculties_usecase.dart';
import 'package:kempa/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kempa/features/auth/domain/repositories/auth_repository.dart';
import 'package:kempa/features/auth/domain/usecases/auth_update_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kempa/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kempa/features/auth/presentation/pages/splash_screen.dart';
import 'package:kempa/features/schedule/data/datasources/schedule_remote_datasource.dart';
import 'package:kempa/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:kempa/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:kempa/features/schedule/domain/usecases/get_day_info.dart';
import 'package:kempa/features/schedule/presentation/bloc/schedule_bloc.dart';
import '../network/api_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(() => ThemeBloc(sl())..add(ThemeLoaded()));

  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(), 
    checkAuthUsecase: sl(),
    logoutUsecase: sl(),
    authUpdateUseCase: sl()
  ));

  sl.registerLazySingleton(() => LoginUseCase(sl()));

  sl.registerLazySingleton(() => CheckAuthUsecase(sl()));

  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  sl.registerLazySingleton(() => AuthUpdateUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      tokenManager: sl()
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton(() => ApiClient(sl()));

  const storage = FlutterSecureStorage();
  sl.registerLazySingleton(() => storage);
  sl.registerLazySingleton(() => TokenManager(sl()));

  sl.registerFactory(() => ScheduleBloc(getDayInfo: sl()));

  sl.registerLazySingleton(() => GetDayInfo(sl()));

  sl.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ScheduleRemoteDatasource>(
    () => ScheduleRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<SplashController>(() => SplashController());

  sl.registerLazySingleton<AcademicRemoteDatasource>(
    () => AcademicRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<AcademicRepository>(
    () => AcademicRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(
    () => GetFacultiesUseCase(sl()),
  );
}