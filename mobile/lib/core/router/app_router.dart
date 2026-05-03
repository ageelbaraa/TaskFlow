import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/board/domain/entities/task_card_entity.dart';
import '../../features/board/presentation/pages/board_detail_page.dart';
import '../../features/board/presentation/pages/boards_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';

class Routes {
  Routes._();
  static const login = 'login';
  static const register = 'register';
  static const boards = 'boards';
  static const boardDetail = 'board-detail';
  static const taskDetail = 'task-detail';
}

class AppRouter {
  AppRouter(AuthBloc Function() authBlocFactory)
      : _authBlocFactory = authBlocFactory;

  final AuthBloc Function() _authBlocFactory;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _RouterNotifier(_authBlocFactory),
    redirect: (context, state) {
      final isAuthenticated =
          _authBlocFactory().state is AuthAuthenticated;
      final isOnAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isOnAuthRoute) return '/login';
      if (isAuthenticated && isOnAuthRoute) return '/boards';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: Routes.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: Routes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: '/boards',
        name: Routes.boards,
        builder: (_, __) => const BoardsPage(),
        routes: [
          GoRoute(
            path: ':boardId',
            name: Routes.boardDetail,
            builder: (_, state) => BoardDetailPage(
              boardId: state.pathParameters['boardId']!,
            ),
            routes: [
              GoRoute(
                path: 'cards/:cardId',
                name: Routes.taskDetail,
                builder: (_, state) {
                  // TaskCardEntity is passed as route extra to avoid a
                  // redundant network fetch — the card data is already loaded
                  // in BoardDetailPage's state.
                  final card = state.extra as TaskCardEntity;
                  return TaskDetailPage(card: card);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(AuthBloc Function() factory) {
    factory().stream.listen((_) => notifyListeners());
  }
}
