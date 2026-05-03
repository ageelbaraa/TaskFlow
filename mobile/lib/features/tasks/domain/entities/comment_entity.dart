import 'package:equatable/equatable.dart';

class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.taskCardId,
    required this.boardId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String taskCardId;
  final String boardId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, taskCardId, boardId, authorId, authorName, body, createdAt];
}
