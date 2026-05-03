import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/online_user_entity.dart';
import '../../domain/entities/task_card_entity.dart';
import '../bloc/board_detail/board_detail_bloc.dart';
import '../bloc/board_detail/board_detail_event.dart';
import '../bloc/board_detail/board_detail_state.dart';
import '../widgets/create_board_dialog.dart';
import '../widgets/kanban_column_widget.dart';

class BoardDetailPage extends StatelessWidget {
  const BoardDetailPage({super.key, required this.boardId});

  final String boardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BoardDetailBloc>(
      create: (_) =>
          getIt<BoardDetailBloc>()..add(BoardDetailLoadEvent(boardId)),
      child: PopScope(
        canPop: true,
        child: _BoardDetailView(boardId: boardId),
      ),
    );
  }
}

class _BoardDetailView extends StatelessWidget {
  const _BoardDetailView({required this.boardId});

  final String boardId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BoardDetailBloc, BoardDetailState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: state is BoardDetailLoaded
                ? Text(state.board.name)
                : const Text('Board'),
            actions: [
              if (state is BoardDetailLoaded && state.onlineUsers.isNotEmpty)
                _OnlineAvatarRow(users: state.onlineUsers),
              if (state is BoardDetailLoaded)
                IconButton(
                  icon: const Icon(Icons.add_box_outlined),
                  tooltip: 'Add column',
                  onPressed: () => _showAddColumn(context, state.board.id),
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<BoardDetailBloc>()
                    .add(BoardDetailLoadEvent(boardId)),
              ),
            ],
          ),
          body: switch (state) {
            BoardDetailInitial() ||
            BoardDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            BoardDetailError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(message),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<BoardDetailBloc>()
                          .add(BoardDetailLoadEvent(boardId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            BoardDetailLoaded(:final board) => board.columns.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('No columns yet.'),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _showAddColumn(context, board.id),
                          icon: const Icon(Icons.add),
                          label: const Text('Add column'),
                        ),
                      ],
                    ),
                  )
                : ScrollConfiguration(
                    behavior: _HorizontalScrollBehavior(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...board.columns.map(
                            (col) => KanbanColumnWidget(
                              key: ValueKey(col.id),
                              column: col,
                              onCardDropped: (card, toColumnId, order) =>
                                  context.read<BoardDetailBloc>().add(
                                        BoardDetailMoveCardEvent(
                                          cardId: card.id,
                                          fromColumnId: card.columnId,
                                          toColumnId: toColumnId,
                                          newOrder: order,
                                        ),
                                      ),
                              onAddCard: (colId) =>
                                  _showAddCard(context, colId),
                              onCardTap: (card) =>
                                  _navigateToTask(context, card),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 20),
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _showAddColumn(context, board.id),
                              icon: const Icon(Icons.add),
                              label: const Text('Add column'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          },
        );
      },
    );
  }

  void _showAddColumn(BuildContext context, String currentBoardId) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateNameDialog(
        title: 'New Column',
        hint: 'e.g. In Progress',
        onConfirm: (title) => context.read<BoardDetailBloc>().add(
              BoardDetailAddColumnEvent(boardId: currentBoardId, title: title),
            ),
      ),
    );
  }

  void _showAddCard(BuildContext context, String columnId) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateNameDialog(
        title: 'New Card',
        hint: 'Card title',
        onConfirm: (title) => context.read<BoardDetailBloc>().add(
              BoardDetailAddCardEvent(columnId: columnId, title: title),
            ),
      ),
    );
  }

  void _navigateToTask(BuildContext context, TaskCardEntity card) {
    context.pushNamed(
      Routes.taskDetail,
      pathParameters: {
        'boardId': boardId,
        'cardId': card.id,
      },
      extra: card,
    );
  }
}

// ── Online avatars ────────────────────────────────────────────────────────────

class _OnlineAvatarRow extends StatelessWidget {
  const _OnlineAvatarRow({required this.users});

  final List<OnlineUserEntity> users;

  static const _maxVisible = 4;

  @override
  Widget build(BuildContext context) {
    final visible = users.take(_maxVisible).toList();
    final overflow = users.length - _maxVisible;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...visible.map(
            (u) => Tooltip(
              message: u.userName,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: _colorForName(u.userName),
                  child: Text(
                    u.userName.isNotEmpty
                        ? u.userName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          if (overflow > 0)
            CircleAvatar(
              radius: 14,
              backgroundColor: Colors.grey,
              child: Text(
                '+$overflow',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Color _colorForName(String name) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
    ];
    if (name.isEmpty) return Colors.grey;
    return colors[name.codeUnitAt(0) % colors.length];
  }
}

class _HorizontalScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}
