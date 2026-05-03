import '../../../../core/network/api_client.dart';
import '../models/comment_model.dart';

class CommentRemoteDataSource {
  const CommentRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CommentModel>> getComments(String taskCardId) async {
    final response =
        await _client.dio.get('/tasks/$taskCardId/comments');
    return (response.data as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommentModel> addComment(String taskCardId, String body) async {
    final response = await _client.dio.post(
      '/tasks/$taskCardId/comments',
      data: {'body': body},
    );
    return CommentModel.fromJson(response.data as Map<String, dynamic>);
  }
}
