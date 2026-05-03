import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/board/data/services/board_hub_service.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/repositories/comment_repository.dart';
import 'comment_event.dart';
import 'comment_state.dart';

/// Loads and maintains the live comment feed for a single task card.
///
/// Comments arrive via two channels:
/// 1. REST GET on [CommentLoadEvent] for the initial full list.
/// 2. SignalR [CommentAdded] broadcast filtered to this card's id.
class CommentBloc extends Bloc<CommentEvent, CommentState> {
  CommentBloc({
    required CommentRepository repo,
    required BoardHubService hubService,
    required String taskCardId,
  })  : _repo = repo,
        _hubService = hubService,
        _taskCardId = taskCardId,
        super(const CommentInitial()) {
    on<CommentLoadEvent>(_onLoad);
    on<CommentSubmitEvent>(_onSubmit);
    on<CommentReceivedEvent>(_onReceived);

    // Subscribe to the singleton hub's commentAdded stream and filter to
    // comments that belong to this card.
    _hubSub = _hubService.commentAdded
        .where((e) => e.taskCardId == taskCardId)
        .listen((e) {
      add(CommentReceivedEvent(_hubEventToEntity(e)));
    });
  }

  final CommentRepository _repo;
  final BoardHubService _hubService;
  final String _taskCardId;
  late final StreamSubscription<CommentAddedEvent> _hubSub;

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      CommentLoadEvent event, Emitter<CommentState> emit) async {
    emit(const CommentLoading());
    try {
      final comments = await _repo.getComments(event.taskCardId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSubmit(
      CommentSubmitEvent event, Emitter<CommentState> emit) async {
    if (state is! CommentLoaded) return;
    final current = state as CommentLoaded;
    emit(current.copyWith(submitting: true));
    try {
      // The REST call persists the comment; the hub will broadcast it back
      // via CommentAdded, which _onReceived deduplicates.
      await _repo.addComment(event.taskCardId, event.body);
      emit(current.copyWith(submitting: false));
    } catch (e) {
      emit(CommentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _onReceived(
      CommentReceivedEvent event, Emitter<CommentState> emit) {
    if (state is! CommentLoaded) return;
    final current = state as CommentLoaded;

    // Deduplicate: the user who posted already sees the optimistic UI; the
    // hub echo confirms it. Skip if already present by id.
    final exists = current.comments.any((c) => c.id == event.comment.id);
    if (exists) return;

    emit(current.copyWith(
      comments: [...current.comments, event.comment],
    ));
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _hubSub.cancel();
    return super.close();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static CommentEntity _hubEventToEntity(CommentAddedEvent e) => CommentEntity(
        id: e.id,
        taskCardId: e.taskCardId,
        boardId: e.boardId,
        authorId: e.authorId,
        authorName: e.authorName,
        body: e.body,
        createdAt: DateTime.tryParse(e.createdAt) ?? DateTime.now(),
      );

  /// Convenience: trigger initial load.
  void load() => add(CommentLoadEvent(_taskCardId));
}
