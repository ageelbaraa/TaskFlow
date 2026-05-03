import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/board_list/board_list_bloc.dart';
import '../bloc/board_list/board_list_event.dart';
import '../bloc/board_list/board_list_state.dart';
import '../widgets/create_board_dialog.dart';

/// Displays the list of boards accessible to the current user.
class BoardsPage extends StatelessWidget {
  const BoardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BoardListBloc>(
      create: (_) => getIt<BoardListBloc>()..add(const BoardListLoadEvent()),
      child: const _BoardsView(),
    );
  }
}

class _BoardsView extends StatelessWidget {
  const _BoardsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Boards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutEvent());
              context.goNamed(Routes.login);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New board'),
        onPressed: () => _showCreateDialog(context),
      ),
      body: BlocBuilder<BoardListBloc, BoardListState>(
        builder: (context, state) {
          if (state is BoardListLoading || state is BoardListInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BoardListError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<BoardListBloc>()
                        .add(const BoardListLoadEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is BoardListLoaded) {
            if (state.boards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_outlined,
                        size: 64, color: theme.colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    const Text('No boards yet — create one!'),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<BoardListBloc>()
                  .add(const BoardListLoadEvent()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.boards.length,
                itemBuilder: (context, index) {
                  final board = state.boards[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          board.name[0].toUpperCase(),
                          style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text(board.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${board.columnCount} columns · '
                        '${board.memberCount} members · '
                        'Created ${DateFormat.yMMMd().format(board.createdAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context
                            .read<BoardListBloc>()
                            .add(BoardListDeleteEvent(board.id)),
                      ),
                      onTap: () => context.goNamed(
                        Routes.boardDetail,
                        pathParameters: {'boardId': board.id},
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateNameDialog(
        title: 'New Board',
        hint: 'e.g. Sprint 12',
        onConfirm: (name) =>
            context.read<BoardListBloc>().add(BoardListCreateEvent(name)),
      ),
    );
  }
}
