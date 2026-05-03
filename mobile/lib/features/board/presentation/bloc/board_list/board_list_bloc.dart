import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/board_repository.dart';
import 'board_list_event.dart';
import 'board_list_state.dart';

/// Manages the boards list screen state.
class BoardListBloc extends Bloc<BoardListEvent, BoardListState> {
  BoardListBloc(this._repo) : super(const BoardListInitial()) {
    on<BoardListLoadEvent>(_onLoad);
    on<BoardListCreateEvent>(_onCreate);
    on<BoardListDeleteEvent>(_onDelete);
  }

  final BoardRepository _repo;

  Future<void> _onLoad(BoardListLoadEvent event, Emitter<BoardListState> emit) async {
    emit(const BoardListLoading());
    try {
      final boards = await _repo.getBoards();
      emit(BoardListLoaded(boards));
    } catch (e) {
      emit(BoardListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCreate(BoardListCreateEvent event, Emitter<BoardListState> emit) async {
    try {
      await _repo.createBoard(event.name);
      add(const BoardListLoadEvent());
    } catch (e) {
      emit(BoardListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDelete(BoardListDeleteEvent event, Emitter<BoardListState> emit) async {
    try {
      await _repo.deleteBoard(event.boardId);
      add(const BoardListLoadEvent());
    } catch (e) {
      emit(BoardListError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
