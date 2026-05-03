import 'package:equatable/equatable.dart';

import '../../../domain/entities/board_entity.dart';
import '../../../domain/entities/online_user_entity.dart';

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
  const BoardDetailLoaded(this.board, {this.onlineUsers = const []});
  final BoardDetailEntity board;
  final List<OnlineUserEntity> onlineUsers;

  BoardDetailLoaded copyWithUsers(List<OnlineUserEntity> users) =>
      BoardDetailLoaded(board, onlineUsers: users);

  BoardDetailLoaded copyWithBoard(BoardDetailEntity newBoard) =>
      BoardDetailLoaded(newBoard, onlineUsers: onlineUsers);

  @override
  List<Object?> get props => [board, onlineUsers];
}

final class BoardDetailError extends BoardDetailState {
  const BoardDetailError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
