import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../router/app_router.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/board/data/datasources/board_remote_datasource.dart';
import '../../features/board/data/repositories/board_repository_impl.dart';
import '../../features/board/domain/repositories/board_repository.dart';
import '../../features/board/presentation/bloc/board_detail/board_detail_bloc.dart';
import '../../features/board/presentation/bloc/board_list/board_list_bloc.dart';

final GetIt getIt = GetIt.instance;

/// Registers all application-level singletons and factories.
Future<void> configureDependencies() async {
  // ── Core ─────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<SecureStorageService>()));
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(() => getIt<AuthBloc>()));

  // ── Auth ──────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<ApiClient>()));
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>(), getIt<SecureStorageService>()));
  getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt<AuthRepository>()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
        loginUseCase: getIt<LoginUseCase>(),
        registerUseCase: getIt<RegisterUseCase>(),
        storageService: getIt<SecureStorageService>(),
      ));

  // ── Board ─────────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<BoardRemoteDataSource>(
      () => BoardRemoteDataSource(getIt<ApiClient>()));
  getIt.registerLazySingleton<BoardRepository>(
      () => BoardRepositoryImpl(getIt<BoardRemoteDataSource>()));
  getIt.registerFactory<BoardListBloc>(() => BoardListBloc(getIt<BoardRepository>()));
  getIt.registerFactory<BoardDetailBloc>(() => BoardDetailBloc(getIt<BoardRepository>()));
}
