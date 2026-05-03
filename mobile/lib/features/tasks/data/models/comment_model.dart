import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.taskCardId,
    required super.boardId,
    required super.authorId,
    required super.authorName,
    required super.body,
    required super.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json['id'] as String,
        taskCardId: json['taskCardId'] as String,
        boardId: json['boardId'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
