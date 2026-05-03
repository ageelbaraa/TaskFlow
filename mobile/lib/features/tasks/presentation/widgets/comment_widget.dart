import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/comment_entity.dart';

class CommentWidget extends StatelessWidget {
  const CommentWidget({super.key, required this.comment});

  final CommentEntity comment;

  static final _timeFmt = DateFormat('MMM d, HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _colorForName(comment.authorName),
            child: Text(
              comment.authorName.isNotEmpty
                  ? comment.authorName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _timeFmt.format(comment.createdAt.toLocal()),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: theme.textTheme.bodyMedium),
              ],
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
