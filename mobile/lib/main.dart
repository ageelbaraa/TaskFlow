import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const TaskBoardApp());
}

class TaskBoardApp extends StatelessWidget {
  const TaskBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => getIt<AuthBloc>()..add(const AuthCheckStatusEvent()),
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        listener: (context, state) {
          // GoRouter's redirect logic reads AuthBloc state — refresh on changes.
          getIt<AppRouter>().router.refresh();
        },
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              title: 'TaskBoard',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              routerConfig: getIt<AppRouter>().router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
