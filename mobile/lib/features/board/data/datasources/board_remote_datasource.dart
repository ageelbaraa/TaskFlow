import '../../../../core/network/api_client.dart';
import '../../domain/entities/board_entity.dart';
import '../../domain/entities/column_entity.dart';
import '../../domain/entities/task_card_entity.dart';
import '../models/board_model.dart';

/// Calls the remote board/column/card REST endpoints.
class BoardRemoteDataSource {
  const BoardRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<BoardSummaryEntity>> getBoards() async {
    final res = await _client.dio.get<List<dynamic>>('/boards');
    return (res.data ?? [])
        .map((e) => BoardSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BoardDetailEntity> getBoardById(String id) async {
    final res = await _client.dio.get<Map<String, dynamic>>('/boards/$id');
    return BoardDetailModel.fromJson(res.data!);
  }

  Future<BoardSummaryEntity> createBoard(String name) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/boards',
      data: {'name': name},
    );
    return BoardSummaryModel.fromJson(res.data!);
  }

  Future<BoardSummaryEntity> updateBoard(String id, String name) async {
    final res = await _client.dio.put<Map<String, dynamic>>(
      '/boards/$id',
      data: {'name': name},
    );
    return BoardSummaryModel.fromJson(res.data!);
  }

  Future<void> deleteBoard(String id) =>
      _client.dio.delete<void>('/boards/$id');

  Future<ColumnEntity> createColumn(String boardId, String title) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/boards/$boardId/columns',
      data: {'title': title},
    );
    return ColumnModel.fromJson(res.data!);
  }

  Future<ColumnEntity> updateColumn(
      String boardId, String columnId, String title) async {
    final res = await _client.dio.put<Map<String, dynamic>>(
      '/boards/$boardId/columns/$columnId',
      data: {'title': title},
    );
    return ColumnModel.fromJson(res.data!);
  }

  Future<void> deleteColumn(String boardId, String columnId) =>
      _client.dio.delete<void>('/boards/$boardId/columns/$columnId');

  Future<TaskCardEntity> createCard({
    required String columnId,
    required String title,
    String? description,
    String? assigneeId,
    String priority = 'Medium',
    DateTime? dueDate,
  }) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/cards',
      data: {
        'columnId': columnId,
        'title': title,
        'description': description,
        'assigneeId': assigneeId,
        'priority': _priorityIndex(priority),
        'dueDate': dueDate?.toIso8601String(),
      },
    );
    return TaskCardModel.fromJson(res.data!);
  }

  Future<TaskCardEntity> moveCard({
    required String cardId,
    required String toColumnId,
    required int newOrder,
  }) async {
    final res = await _client.dio.patch<Map<String, dynamic>>(
      '/cards/$cardId/move',
      data: {'toColumnId': toColumnId, 'newOrder': newOrder},
    );
    return TaskCardModel.fromJson(res.data!);
  }

  Future<void> deleteCard(String cardId) =>
      _client.dio.delete<void>('/cards/$cardId');

  int _priorityIndex(String priority) => switch (priority) {
        'Low' => 0,
        'Medium' => 1,
        'High' => 2,
        'Critical' => 3,
        _ => 1,
      };
}
