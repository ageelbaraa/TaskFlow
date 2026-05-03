import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';

class CommentRepositoryImpl implements CommentRepository {
  const CommentRepositoryImpl(this._dataSource);

  final CommentRemoteDataSource _dataSource;

  @override
  Future<List<CommentEntity>> getComments(String taskCardId) =>
      _dataSource.getComments(taskCardId);

  @override
  Future<CommentEntity> addComment(String taskCardId, String body) =>
      _dataSource.addComment(taskCardId, body);
}
