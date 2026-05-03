import 'package:equatable/equatable.dart';

import '../../../domain/entities/board_entity.dart';

sealed class BoardDetailState extends Equatable {
  const BoardDetailState();
}

final class BoardDetailInitial extends BoardDetailState {
  const BoardDetailInitial();
  @override
  List<Object?> get props => [];
}

final class BoardDetailLoading extends BoardDetailState {
  const BoardDetailLoading();
  @override
  List<Object?> get props => [];
}

final class BoardDetailLoaded extends BoardDetailState {
  const BoardDetailLoaded(this.board);
  final BoardDetailEntity board;
  @override
  List<Object?> get props => [board];
}

final class BoardDetailError extends BoardDetailState {
  const BoardDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
