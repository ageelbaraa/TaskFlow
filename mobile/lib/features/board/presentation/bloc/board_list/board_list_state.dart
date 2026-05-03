import 'package:equatable/equatable.dart';

import '../../../domain/entities/board_entity.dart';

sealed class BoardListState extends Equatable {
  const BoardListState();
}

final class BoardListInitial extends BoardListState {
  const BoardListInitial();
  @override
  List<Object?> get props => [];
}

final class BoardListLoading extends BoardListState {
  const BoardListLoading();
  @override
  List<Object?> get props => [];
}

final class BoardListLoaded extends BoardListState {
  const BoardListLoaded(this.boards);
  final List<BoardSummaryEntity> boards;
  @override
  List<Object?> get props => [boards];
}

final class BoardListError extends BoardListState {
  const BoardListError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
