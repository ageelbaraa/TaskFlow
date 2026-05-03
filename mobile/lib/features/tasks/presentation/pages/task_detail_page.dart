import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../board/domain/entities/task_card_entity.dart';
import '../bloc/comment_bloc.dart';
import '../bloc/comment_event.dart';
import '../bloc/comment_state.dart';
import '../widgets/comment_widget.dart';

/// Full-screen task card detail with live comment feed.
///
/// Receives the [TaskCardEntity] as route extra so no extra network call
/// is needed to show card metadata. Comments are loaded via REST and then
/// kept live via the shared [BoardHubService] SignalR stream.
class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.card});

  final TaskCardEntity card;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CommentBloc>(
      create: (_) => getIt<CommentBloc>(param1: card.id)..load(),
      child: _TaskDetailView(card: card),
    );
  }
}

class _TaskDetailView extends StatefulWidget {
  const _TaskDetailView({required this.card});
  final TaskCardEntity card;

  @override
  State<_TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<_TaskDetailView> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final body = _ctrl.text.trim();
    if (body.isEmpty) return;
    context.read<CommentBloc>().add(
          CommentSubmitEvent(taskCardId: widget.card.id, body: body),
        );
    _ctrl.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = widget.card;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          card.title,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          // ── Card metadata ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _PriorityChip(priority: card.priority),
                    if (card.assigneeName != null)
                      Chip(
                        avatar: const Icon(Icons.person_outline, size: 16),
                        label: Text(card.assigneeName!),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (card.dueDate != null)
                      Chip(
                        avatar:
                            const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(card.dueDate!.toLocal().toString().split(' ')[0]),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                if (card.description != null &&
                    card.description!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(card.description!, style: theme.textTheme.bodyMedium),
                ],
                const Divider(height: 24),
                Text('Comments', style: theme.textTheme.titleSmall),
              ],
            ),
          ),

          // ── Comment list ───────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) => switch (state) {
                CommentInitial() || CommentLoading() =>
                  const Center(child: CircularProgressIndicator()),
                CommentError(:final message) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => context
                              .read<CommentBloc>()
                              .add(CommentLoadEvent(card.id)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                CommentLoaded(:final comments) => comments.isEmpty
                    ? const Center(child: Text('No comments yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (_, i) =>
                            CommentWidget(comment: comments[i]),
                      ),
              },
            ),
          ),

          // ── Comment input ──────────────────────────────────────────────
          _CommentInput(
            ctrl: _ctrl,
            focusNode: _focusNode,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  const _CommentInput({
    required this.ctrl,
    required this.focusNode,
    required this.onSubmit,
  });

  final TextEditingController ctrl;
  final FocusNode focusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentBloc, CommentState>(
      builder: (context, state) {
        final submitting = state is CommentLoaded && state.submitting;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 8,
              top: 8,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSubmit(),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment…',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    maxLines: null,
                  ),
                ),
                const SizedBox(width: 8),
                submitting
                    ? const SizedBox(
                        width: 40,
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton.filled(
                        icon: const Icon(Icons.send),
                        onPressed: onSubmit,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority.toLowerCase()) {
      'critical' => Colors.red,
      'high' => Colors.orange,
      'medium' => Colors.blue,
      _ => Colors.grey,
    };
    return Chip(
      label: Text(priority),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.4)),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      visualDensity: VisualDensity.compact,
    );
  }
}
