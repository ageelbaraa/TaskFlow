import 'package:equatable/equatable.dart';

import '../../domain/entities/comment_entity.dart';

sealed class CommentEvent extends Equatable {
  const CommentEvent();
}

final class CommentLoadEvent extends CommentEvent {
  const CommentLoadEvent(this.taskCardId);
  final String taskCardId;
  @override
  List<Object?> get props => [taskCardId];
}

final class CommentSubmitEvent extends CommentEvent {
  const CommentSubmitEvent({required this.taskCardId, required this.body});
  final String taskCardId;
  final String body;
  @override
  List<Object?> get props => [taskCardId, body];
}

/// Injected by the hub stream when a new comment arrives via SignalR.
final class CommentReceivedEvent extends CommentEvent {
  const CommentReceivedEvent(this.comment);
  final CommentEntity comment;
  @override
  List<Object?> get props => [comment];
}
