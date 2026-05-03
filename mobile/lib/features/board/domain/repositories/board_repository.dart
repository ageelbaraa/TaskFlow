import '../entities/board_entity.dart';
import '../entities/task_card_entity.dart';

/// Contract for all board, column, and card operations.
abstract class BoardRepository {
  /// Returns all boards visible to the current user.
  Future<List<BoardSummaryEntity>> getBoards();

  /// Returns full board detail with columns and cards.
  Future<BoardDetailEntity> getBoardById(String boardId);

  /// Creates a new board with the given name.
  Future<BoardSummaryEntity> createBoard(String name);

  /// Renames a board.
  Future<BoardSummaryEntity> updateBoard(String boardId, String name);

  /// Deletes a board.
  Future<void> deleteBoard(String boardId);

  /// Adds a column to a board.
  Future<void> createColumn(String boardId, String title);

  /// Renames a column.
  Future<void> updateColumn(String boardId, String columnId, String title);

  /// Deletes a column.
  Future<void> deleteColumn(String boardId, String columnId);

  /// Creates a task card in the specified column.
  Future<TaskCardEntity> createCard({
    required String columnId,
    required String title,
    String? description,
    String? assigneeId,
    String priority,
    DateTime? dueDate,
  });

  /// Moves a card to a column at the given order index. Returns the updated card.
  Future<TaskCardEntity> moveCard({
    required String cardId,
    required String toColumnId,
    required int newOrder,
  });

  /// Deletes a task card.
  Future<void> deleteCard(String cardId);
}
