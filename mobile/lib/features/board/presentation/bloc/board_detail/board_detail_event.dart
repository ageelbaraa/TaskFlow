import 'package:equatable/equatable.dart';

import '../../../domain/entities/online_user_entity.dart';

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

// ── Presence events ───────────────────────────────────────────────────────────

/// Emitted when the hub sends back the initial list of online users on join.
final class BoardDetailUsersLoadedEvent extends BoardDetailEvent {
  const BoardDetailUsersLoadedEvent(this.users);
  final List<OnlineUserEntity> users;
  @override
  List<Object?> get props => [users];
}

final class BoardDetailUserJoinedEvent extends BoardDetailEvent {
  const BoardDetailUserJoinedEvent({
    required this.userId,
    required this.userName,
  });
  final String userId;
  final String userName;
  @override
  List<Object?> get props => [userId, userName];
}

final class BoardDetailUserLeftEvent extends BoardDetailEvent {
  const BoardDetailUserLeftEvent(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}
