import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/board_hub_service.dart';
import '../../../domain/entities/column_entity.dart';
import '../../../domain/entities/online_user_entity.dart';
import '../../../domain/entities/task_card_entity.dart';
import '../../../domain/repositories/board_repository.dart';
import 'board_detail_event.dart';
import 'board_detail_state.dart';

class BoardDetailBloc extends Bloc<BoardDetailEvent, BoardDetailState> {
  BoardDetailBloc({
    required BoardRepository repo,
    required BoardHubService hubService,
  })  : _repo = repo,
        _hubService = hubService,
        super(const BoardDetailInitial()) {
    on<BoardDetailLoadEvent>(_onLoad);
    on<BoardDetailAddColumnEvent>(_onAddColumn);
    on<BoardDetailAddCardEvent>(_onAddCard);
    on<BoardDetailMoveCardEvent>(_onMoveCard);
    on<BoardDetailCardMovedServerEvent>(_onServerCardMoved);
    on<BoardDetailUsersLoadedEvent>(_onUsersLoaded);
    on<BoardDetailUserJoinedEvent>(_onUserJoined);
    on<BoardDetailUserLeftEvent>(_onUserLeft);
  }

  final BoardRepository _repo;
  final BoardHubService _hubService;

  final List<StreamSubscription<dynamic>> _subs = [];
  String? _currentBoardId;

  // ── Event handlers ────────────────────────────────────────────────────────

  Future<void> _onLoad(
      BoardDetailLoadEvent event, Emitter<BoardDetailState> emit) async {
    emit(const BoardDetailLoading());
    try {
      final board = await _repo.getBoardById(event.boardId);
      emit(BoardDetailLoaded(board));
      await _connectHub(event.boardId);
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddColumn(
      BoardDetailAddColumnEvent event, Emitter<BoardDetailState> emit) async {
    try {
      await _repo.createColumn(event.boardId, event.title);
      add(BoardDetailLoadEvent(event.boardId));
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAddCard(
      BoardDetailAddCardEvent event, Emitter<BoardDetailState> emit) async {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    try {
      final card = await _repo.createCard(
        columnId: event.columnId,
        title: event.title,
        priority: event.priority,
      );
      final updatedColumns = current.board.columns.map((col) {
        if (col.id != event.columnId) return col;
        return col.copyWith(cards: [...col.cards, card]);
      }).toList();
      emit(current.copyWithBoard(current.board.copyWith(columns: updatedColumns)));
    } catch (e) {
      emit(BoardDetailError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onMoveCard(
      BoardDetailMoveCardEvent event, Emitter<BoardDetailState> emit) async {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    emit(current.copyWithBoard(current.board.copyWith(
      columns: _applyMove(current.board.columns, event.cardId,
          event.fromColumnId, event.toColumnId, event.newOrder),
    )));

    try {
      if (_hubService.isConnected) {
        await _hubService.moveCard(
          cardId: event.cardId,
          toColumnId: event.toColumnId,
          newOrder: event.newOrder,
        );
      } else {
        await _repo.moveCard(
          cardId: event.cardId,
          toColumnId: event.toColumnId,
          newOrder: event.newOrder,
        );
      }
    } catch (_) {
      add(BoardDetailLoadEvent(current.board.id));
    }
  }

  void _onServerCardMoved(
      BoardDetailCardMovedServerEvent event, Emitter<BoardDetailState> emit) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;

    final fromColId = current.board.columns
        .where((c) => c.cards.any((t) => t.id == event.cardId))
        .map((c) => c.id)
        .firstOrNull;

    if (fromColId == null) return;

    emit(current.copyWithBoard(current.board.copyWith(
      columns: _applyMove(current.board.columns, event.cardId, fromColId,
          event.toColumnId, event.newOrder),
    )));
  }

  // ── Presence handlers ─────────────────────────────────────────────────────

  void _onUsersLoaded(
      BoardDetailUsersLoadedEvent event, Emitter<BoardDetailState> emit) {
    if (state is! BoardDetailLoaded) return;
    emit((state as BoardDetailLoaded).copyWithUsers(event.users));
  }

  void _onUserJoined(
      BoardDetailUserJoinedEvent event, Emitter<BoardDetailState> emit) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    final already = current.onlineUsers.any((u) => u.userId == event.userId);
    if (already) return;
    emit(current.copyWithUsers([
      ...current.onlineUsers,
      OnlineUserEntity(userId: event.userId, userName: event.userName),
    ]));
  }

  void _onUserLeft(
      BoardDetailUserLeftEvent event, Emitter<BoardDetailState> emit) {
    if (state is! BoardDetailLoaded) return;
    final current = state as BoardDetailLoaded;
    emit(current.copyWithUsers(
      current.onlineUsers.where((u) => u.userId != event.userId).toList(),
    ));
  }

  // ── Hub lifecycle ─────────────────────────────────────────────────────────

  Future<void> _connectHub(String boardId) async {
    await _cancelSubs();
    _currentBoardId = boardId;

    List<OnlineUserEntity> initial = [];
    try {
      initial = await _hubService.connect(boardId);
    } catch (_) {
      return;
    }

    // Seed initial presence list from JoinBoard return value.
    add(BoardDetailUsersLoadedEvent(initial));

    _subs.add(
      _hubService.cardMoved.listen((event) {
        add(BoardDetailCardMovedServerEvent(
          cardId: event.cardId,
          toColumnId: event.toColumnId,
          newOrder: event.newOrder,
        ));
      }),
    );

    _subs.add(
      _hubService.userJoined.listen((event) {
        add(BoardDetailUserJoinedEvent(
          userId: event.userId,
          userName: event.userName ?? event.userId,
        ));
      }),
    );

    _subs.add(
      _hubService.userLeft.listen((event) {
        add(BoardDetailUserLeftEvent(event.userId));
      }),
    );
  }

  Future<void> _cancelSubs() async {
    for (final sub in _subs) {
      await sub.cancel();
    }
    _subs.clear();
  }

  // ── Bloc lifecycle ────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    if (_currentBoardId != null) {
      await _hubService.disconnect(_currentBoardId!);
    }
    await _cancelSubs();
    return super.close();
  }

  // ── Optimistic move helper ────────────────────────────────────────────────

  List<ColumnEntity> _applyMove(
    List<ColumnEntity> columns,
    String cardId,
    String fromColId,
    String toColId,
    int newOrder,
  ) {
    TaskCardEntity? movedCard;

    final removed = columns.map((col) {
      if (col.id != fromColId) return col;
      final idx = col.cards.indexWhere((t) => t.id == cardId);
      if (idx == -1) return col;
      movedCard = col.cards[idx];
      final list = List<TaskCardEntity>.from(col.cards)..removeAt(idx);
      return col.copyWith(
        cards: list.indexed.map((e) => e.$2.copyWith(order: e.$1)).toList(),
      );
    }).toList();

    if (movedCard == null) return columns;
    final card = movedCard!.copyWith(columnId: toColId, order: newOrder);

    return removed.map((col) {
      if (col.id != toColId) return col;
      final list = List<TaskCardEntity>.from(col.cards)
        ..insert(newOrder.clamp(0, col.cards.length), card);
      return col.copyWith(
        cards: list.indexed.map((e) => e.$2.copyWith(order: e.$1)).toList(),
      );
    }).toList();
  }
}
