import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task_card_entity.dart';

/// Draggable task card tile rendered inside a Kanban column.
class TaskCardWidget extends StatelessWidget {
  const TaskCardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  final TaskCardEntity card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LongPressDraggable<TaskCardEntity>(
      data: card,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 240,
          child: _CardBody(card: card, theme: theme, dragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _CardBody(card: card, theme: theme, dragging: false),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _CardBody(card: card, theme: theme, dragging: false),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.card,
    required this.theme,
    required this.dragging,
  });

  final TaskCardEntity card;
  final ThemeData theme;
  final bool dragging;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PriorityChip(priority: card.priority),
                const Spacer(),
                if (card.commentCount > 0)
                  Row(
                    children: [
                      Icon(Icons.comment_outlined,
                          size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text('${card.commentCount}',
                          style: theme.textTheme.labelSmall),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(card.title,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (card.dueDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 13, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 3),
                  Text(
                    DateFormat.MMMd().format(card.dueDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: card.dueDate!.isBefore(DateTime.now())
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (card.assigneeName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      card.assigneeName![0].toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(card.assigneeName!,
                        style: theme.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      'Critical' => Colors.red,
      'High' => Colors.orange,
      'Medium' => Colors.blue,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(priority,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
