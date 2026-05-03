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
import '../../features/board/data/services/board_hub_service.dart';
import '../../features/board/domain/repositories/board_repository.dart';
import '../../features/board/presentation/bloc/board_detail/board_detail_bloc.dart';
import '../../features/board/presentation/bloc/board_list/board_list_bloc.dart';
import '../../features/tasks/data/datasources/comment_remote_datasource.dart';
import '../../features/tasks/data/repositories/comment_repository_impl.dart';
import '../../features/tasks/domain/repositories/comment_repository.dart';
import '../../features/tasks/presentation/bloc/comment_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── Core ──────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<SecureStorageService>()));
  getIt.registerLazySingleton<AppRouter>(() => AppRouter(() => getIt<AuthBloc>()));

  // ── Auth ──────────────────────────────────────────────────────────────────
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

  // ── Board ─────────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<BoardRemoteDataSource>(
      () => BoardRemoteDataSource(getIt<ApiClient>()));
  getIt.registerLazySingleton<BoardRepository>(
      () => BoardRepositoryImpl(getIt<BoardRemoteDataSource>()));

  // Singleton so BoardDetailBloc and CommentBloc share the same WebSocket.
  getIt.registerLazySingleton<BoardHubService>(
      () => BoardHubService(getIt<SecureStorageService>()));

  getIt.registerFactory<BoardListBloc>(
      () => BoardListBloc(getIt<BoardRepository>()));

  getIt.registerFactory<BoardDetailBloc>(() => BoardDetailBloc(
        repo: getIt<BoardRepository>(),
        hubService: getIt<BoardHubService>(),
      ));

  // ── Tasks / Comments ──────────────────────────────────────────────────────
  getIt.registerLazySingleton<CommentRemoteDataSource>(
      () => CommentRemoteDataSource(getIt<ApiClient>()));
  getIt.registerLazySingleton<CommentRepository>(
      () => CommentRepositoryImpl(getIt<CommentRemoteDataSource>()));

  // CommentBloc is a factory with param1 = taskCardId so each TaskDetailPage
  // gets its own instance scoped to that card.
  getIt.registerFactoryParam<CommentBloc, String, void>(
    (taskCardId, _) => CommentBloc(
      repo: getIt<CommentRepository>(),
      hubService: getIt<BoardHubService>(),
      taskCardId: taskCardId,
    ),
  );
}
