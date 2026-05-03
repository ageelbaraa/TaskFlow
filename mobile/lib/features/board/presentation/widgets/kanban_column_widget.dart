import 'package:flutter/material.dart';

import '../../domain/entities/column_entity.dart';
import '../../domain/entities/task_card_entity.dart';
import 'task_card_widget.dart';

/// A single Kanban column rendered as a fixed-width scrollable lane.
/// Accepts [LongPressDraggable] cards and fires [onCardDropped] on drop.
class KanbanColumnWidget extends StatefulWidget {
  const KanbanColumnWidget({
    super.key,
    required this.column,
    required this.onCardDropped,
    required this.onAddCard,
    required this.onCardTap,
  });

  final ColumnEntity column;

  /// Called when a dragged card is dropped onto this column.
  final void Function(TaskCardEntity card, String toColumnId, int newOrder) onCardDropped;

  /// Called when the user taps the "+" button to add a card.
  final void Function(String columnId) onAddCard;

  /// Called when the user taps a card to open its detail.
  final void Function(TaskCardEntity card) onCardTap;

  @override
  State<KanbanColumnWidget> createState() => _KanbanColumnWidgetState();
}

class _KanbanColumnWidgetState extends State<KanbanColumnWidget> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final col = widget.column;

    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: _isDragOver
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    col.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${col.cards.length}',
                      style: theme.textTheme.labelSmall),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => widget.onAddCard(col.id),
                ),
              ],
            ),
          ),

          // Drop zone + card list
          Expanded(
            child: DragTarget<TaskCardEntity>(
              onWillAcceptWithDetails: (details) {
                setState(() => _isDragOver = true);
                return true;
              },
              onLeave: (_) => setState(() => _isDragOver = false),
              onAcceptWithDetails: (details) {
                setState(() => _isDragOver = false);
                final dropOrder = col.cards.length;
                widget.onCardDropped(details.data, col.id, dropOrder);
              },
              builder: (context, candidateData, rejectedData) {
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: col.cards.length,
                  itemBuilder: (context, index) {
                    final card = col.cards[index];
                    return TaskCardWidget(
                      key: ValueKey(card.id),
                      card: card,
                      onTap: () => widget.onCardTap(card),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
