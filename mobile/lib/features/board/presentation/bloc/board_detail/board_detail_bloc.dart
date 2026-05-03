import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/column_entity.dart';
import '../../../domain/entities/task_card_entity.dart';
import '../../../domain/repositories/board_repository.dart';
import 'board_detail_event.dart';
import 'board_detail_state.dart';

/// Manages Kanban board detail state including optimistic card moves.
class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  BoardDetailBloc(this._repo) : super(const BoardDetailInitial()) {
    on<BoardDetailLoadEvent>(_onLoad);
    on<BoardDetailAddColumnEvent>(_onAddColumn);
    on<BoardDetailAddCardEvent>(_onAddCard);
    on<BoardDetailMoveCardEvent>(_onMoveCard);
    on<BoardDetailCardMovedServerEvent>(_onServerCardMoved);
  }

  final BoardRepository _repo;

  Future<void> _onLoad(BoardDetailLoadEvent event, Emitter<BoardDetailState> emit) async {
    emit(const BoardDetailLoading());
    try {
      final board = await _repo.getBoardById(event.boardId);
      emit(BoardDetailLoaded(board));
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddColumn(BoardDetailAddColumnEvent event, Emitter<BoardDetailState> emit) async {
    try {
      await _repo.createColumn(event.boardId, event.title);
      add(BoardDetailLoadEvent(event.boardId));
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddCard(BoardDetailAddCardEvent event, Emitter<BoardDetailState> emit) async {
    if (state is! BoardDetailLoaded) return;
    final current = (state as BoardDetailLoaded).board;
    try {
      final card = await _repo.createCard(
        columnId: event.columnId,
        title: event.title,
        priority: event.priority,
      );
      final updatedColumns = current.columns.map((col) {
        if (col.id != event.columnId) return col;
        return col.copyWith(cards: [...col.cards, card]);
      }).toList();
      emit(BoardDetailLoaded(current.copyWith(columns: updatedColumns)));
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMoveCard(BoardDetailMoveCardEvent event, Emitter<BoardDetailState> emit) async {
    if (state is! BoardDetailLoaded) return;
    final current = (state as BoardDetailLoaded).board;

    // Optimistic update: reshape column lists immediately
    emit(BoardDetailLoaded(current.copyWith(
      columns: _applyMove(
        current.columns, event.cardId, event.fromColumnId, event.toColumnId, event.newOrder,
      ),
    )));

    // Server confirm — on failure, reload authoritative state
    try {
      await _repo.moveCard(
        cardId: event.cardId,
        toColumnId: event.toColumnId,
        newOrder: event.newOrder,
      );
    } catch (_) {
      add(BoardDetailLoadEvent(current.id));
    }
  }

  void _onServerCardMoved(
      BoardDetailCardMovedServerEvent event, Emitter<BoardDetailState> emit) {
    if (state is! BoardDetailLoaded) return;
    final current = (state as BoardDetailLoaded).board;
    final fromCol = current.columns
        .where((c) => c.cards.any((t) => t.id == event.cardId))
        .map((c) => c.id)
        .firstOrNull;
    if (fromCol == null) return;

    emit(BoardDetailLoaded(current.copyWith(
      columns: _applyMove(
        current.columns, event.cardId, fromCol, event.toColumnId, event.newOrder,
      ),
    )));
  }

  List<ColumnEntity> _applyMove(
    List<ColumnEntity> columns,
    String cardId,
    String fromColId,
    String toColId,
    int newOrder,
  ) {
    TaskCardEntity? movedCard;

    // Remove from source
    final removed = columns.map((col) {
      if (col.id != fromColId) return col;
      final idx = col.cards.indexWhere((t) => t.id == cardId);
      if (idx == -1) return col;
      movedCard = col.cards[idx];
      final newCards = List<TaskCardEntity>.from(col.cards)..removeAt(idx);
      return col.copyWith(
        cards: newCards.indexed.map((e) => e.$2.copyWith(order: e.$1)).toList(),
      );
    }).toList();

    if (movedCard == null) return columns;
    final card = movedCard!.copyWith(columnId: toColId, order: newOrder);

    // Insert into destination
    return removed.map((col) {
      if (col.id != toColId) return col;
      final newCards = List<TaskCardEntity>.from(col.cards)
        ..insert(newOrder.clamp(0, col.cards.length), card);
      return col.copyWith(
        cards: newCards.indexed.map((e) => e.$2.copyWith(order: e.$1)).toList(),
      );
    }).toList();
  }
}
