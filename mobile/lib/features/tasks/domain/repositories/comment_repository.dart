import '../entities/comment_entity.dart';

abstract interface class CommentRepository {
  Future<List<CommentEntity>> getComments(String taskCardId);
  Future<CommentEntity> addComment(String taskCardId, String body);
}
