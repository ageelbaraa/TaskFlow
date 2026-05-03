import 'package:dio/dio.dart';

import '../../domain/entities/board_entity.dart';
import '../../domain/entities/task_card_entity.dart';
import '../../domain/repositories/board_repository.dart';
import '../datasources/board_remote_datasource.dart';

/// Concrete [BoardRepository] backed by the REST API.
class BoardRepositoryImpl implements BoardRepository {
  const BoardRepositoryImpl(this._remote);

  final BoardRemoteDataSource _remote;

  @override
  Future<List<BoardSummaryEntity>> getBoards() => _wrap(_remote.getBoards);

  @override
  Future<BoardDetailEntity> getBoardById(String boardId) =>
      _wrap(() => _remote.getBoardById(boardId));

  @override
  Future<BoardSummaryEntity> createBoard(String name) =>
      _wrap(() => _remote.createBoard(name));

  @override
  Future<BoardSummaryEntity> updateBoard(String boardId, String name) =>
      _wrap(() => _remote.updateBoard(boardId, name));

  @override
  Future<void> deleteBoard(String boardId) =>
      _wrap(() => _remote.deleteBoard(boardId));

  @override
  Future<void> createColumn(String boardId, String title) =>
      _wrap(() => _remote.createColumn(boardId, title));

  @override
  Future<void> updateColumn(
          String boardId, String columnId, String title) =>
      _wrap(() => _remote.updateColumn(boardId, columnId, title));

  @override
  Future<void> deleteColumn(String boardId, String columnId) =>
      _wrap(() => _remote.deleteColumn(boardId, columnId));

  @override
  Future<TaskCardEntity> createCard({
    required String columnId,
    required String title,
    String? description,
    String? assigneeId,
    String priority = 'Medium',
    DateTime? dueDate,
  }) =>
      _wrap(() => _remote.createCard(
            columnId: columnId,
            title: title,
            description: description,
            assigneeId: assigneeId,
            priority: priority,
            dueDate: dueDate,
          ));

  @override
  Future<TaskCardEntity> moveCard({
    required String cardId,
    required String toColumnId,
    required int newOrder,
  }) =>
      _wrap(() => _remote.moveCard(
            cardId: cardId,
            toColumnId: toColumnId,
            newOrder: newOrder,
          ));

  @override
  Future<void> deleteCard(String cardId) =>
      _wrap(() => _remote.deleteCard(cardId));

  Future<T> _wrap<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response!.data as Map)['detail'] as String? ?? 'Request failed'
          : 'Network error';
      throw Exception(msg);
    }
  }
}
