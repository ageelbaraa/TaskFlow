import 'package:equatable/equatable.dart';

sealed class BoardListEvent extends Equatable {
  const BoardListEvent();
}

final class BoardListLoadEvent extends BoardListEvent {
  const BoardListLoadEvent();
  @override
  List<Object?> get props => [];
}

final class BoardListCreateEvent extends BoardListEvent {
  const BoardListCreateEvent(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

final class BoardListDeleteEvent extends BoardListEvent {
  const BoardListDeleteEvent(this.boardId);
  final String boardId;
  @override
  List<Object?> get props => [boardId];
}
