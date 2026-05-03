import 'package:equatable/equatable.dart';

sealed class BoardDetailEvent extends Equatable {
  const BoardDetailEvent();
}

final class BoardDetailLoadEvent extends BoardDetailEvent {
  const BoardDetailLoadEvent(this.boardId);
  final String boardId;
  @override
  List<Object?> get props => [boardId];
}

final class BoardDetailAddColumnEvent extends BoardDetailEvent {
  const BoardDetailAddColumnEvent({required this.boardId, required this.title});
  final String boardId;
  final String title;
  @override
  List<Object?> get props => [boardId, title];
}

final class BoardDetailAddCardEvent extends BoardDetailEvent {
  const BoardDetailAddCardEvent({
    required this.columnId,
    required this.title,
    this.priority = 'Medium',
  });
  final String columnId;
  final String title;
  final String priority;
  @override
  List<Object?> get props => [columnId, title];
}

/// Optimistic card move: update local state immediately, then confirm with server.
final class BoardDetailMoveCardEvent extends BoardDetailEvent {
  const BoardDetailMoveCardEvent({
    required this.cardId,
    required this.fromColumnId,
    required this.toColumnId,
    required this.newOrder,
  });
  final String cardId;
  final String fromColumnId;
  final String toColumnId;
  final int newOrder;
  @override
  List<Object?> get props => [cardId, toColumnId, newOrder];
}

/// Called by SignalR in Phase 3 to push a server-confirmed card position.
final class BoardDetailCardMovedServerEvent extends BoardDetailEvent {
  const BoardDetailCardMovedServerEvent({
    required this.cardId,
    required this.toColumnId,
    required this.newOrder,
  });
  final String cardId;
  final String toColumnId;
  final int newOrder;
  @override
  List<Object?> get props => [cardId, toColumnId, newOrder];
}
