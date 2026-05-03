import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/task_card_entity.dart';
import '../bloc/board_detail/board_detail_bloc.dart';
import '../bloc/board_detail/board_detail_event.dart';
import '../bloc/board_detail/board_detail_state.dart';
import '../widgets/create_board_dialog.dart';
import '../widgets/kanban_column_widget.dart';

/// Full-screen Kanban board with horizontally scrollable columns and draggable cards.
class BoardDetailPage extends StatelessWidget {
  const BoardDetailPage({super.key, required this.boardId});

  final String boardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BoardDetailBloc>(
      create: (_) =>
          getIt<BoardDetailBloc>()..add(BoardDetailLoadEvent(boardId)),
      child: _BoardDetailView(boardId: boardId),
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
                          onPressed: () =>
                              _showAddColumn(context, board.id),
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
                                  _showCardDetail(context, card),
                            ),
                          ),
                          // Trailing "add column" button
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

  void _showCardDetail(BuildContext context, TaskCardEntity card) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CardDetailSheet(card: card),
    );
  }
}

class _CardDetailSheet extends StatelessWidget {
  const _CardDetailSheet({required this.card});
  final TaskCardEntity card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          controller: controller,
          children: [
            Text(card.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(card.priority)),
                if (card.assigneeName != null)
                  Chip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(card.assigneeName!),
                  ),
              ],
            ),
            if (card.description != null && card.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(card.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Text('Comments (${card.commentCount})',
                style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            const Text('Comments feature coming in Phase 4'),
          ],
        ),
      ),
    );
  }
}

/// Enables mouse drag scrolling on desktop/web without showing a scrollbar.
class _HorizontalScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}
