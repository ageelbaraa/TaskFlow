import 'dart:async';

import 'package:signalr_netcore/signalr_netcore.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/online_user_entity.dart';

// ── Event payloads ────────────────────────────────────────────────────────────

class CardMovedEvent {
  const CardMovedEvent({
    required this.cardId,
    required this.fromColumnId,
    required this.toColumnId,
    required this.newOrder,
  });
  final String cardId;
  final String fromColumnId;
  final String toColumnId;
  final int newOrder;
}

class UserPresenceEvent {
  const UserPresenceEvent({
    required this.userId,
    required this.boardId,
    this.userName,
  });
  final String userId;
  final String boardId;
  final String? userName;
}

class CommentAddedEvent {
  const CommentAddedEvent({
    required this.taskCardId,
    required this.id,
    required this.authorName,
    required this.body,
    required this.createdAt,
    required this.boardId,
    required this.authorId,
  });
  final String taskCardId;
  final String id;
  final String authorName;
  final String body;
  final String createdAt;
  final String boardId;
  final String authorId;
}

// ── Service ───────────────────────────────────────────────────────────────────

/// Singleton SignalR service. Shared by [BoardDetailBloc] and [CommentBloc]
/// so both features operate on the same WebSocket connection.
class BoardHubService {
  BoardHubService(this._storage);

  static const _hubPath = '/hubs/board';
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  final SecureStorageService _storage;
  HubConnection? _connection;
  String? _activeBoardId;

  // ── Outbound event streams ─────────────────────────────────────────────────

  final _cardMovedCtrl = StreamController<CardMovedEvent>.broadcast();
  final _userJoinedCtrl = StreamController<UserPresenceEvent>.broadcast();
  final _userLeftCtrl = StreamController<UserPresenceEvent>.broadcast();
  final _commentAddedCtrl = StreamController<CommentAddedEvent>.broadcast();

  Stream<CardMovedEvent> get cardMoved => _cardMovedCtrl.stream;
  Stream<UserPresenceEvent> get userJoined => _userJoinedCtrl.stream;
  Stream<UserPresenceEvent> get userLeft => _userLeftCtrl.stream;
  Stream<CommentAddedEvent> get commentAdded => _commentAddedCtrl.stream;

  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Establishes a hub connection, joins [boardId]'s group, and returns the
  /// initial list of online users so the caller can seed presence state.
  Future<List<OnlineUserEntity>> connect(String boardId) async {
    if (_connection?.state == HubConnectionState.Connected &&
        _activeBoardId == boardId) {
      return getOnlineUsers(boardId);
    }

    await _disconnect();

    final token = await _storage.getToken();

    _connection = HubConnectionBuilder()
        .withUrl(
          '$_baseUrl$_hubPath',
          options: HttpConnectionOptions(
            accessTokenFactory: () async => token ?? '',
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
          ),
        )
        .withAutomaticReconnect(
          retryDelays: [0, 2000, 5000, 10000, 30000],
        )
        .build();

    _registerHandlers();

    await _connection!.start();

    // JoinBoard returns List<{userId, userName}> from the hub.
    final raw = await _connection!.invoke('JoinBoard', args: [boardId]);
    _activeBoardId = boardId;

    return _parseOnlineUsers(raw);
  }

  Future<List<OnlineUserEntity>> getOnlineUsers(String boardId) async {
    if (!isConnected) return [];
    try {
      final raw = await _connection!.invoke('GetOnlineUsers', args: [boardId]);
      return _parseOnlineUsers(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> disconnect(String boardId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('LeaveBoard', args: [boardId]);
      } catch (_) {}
    }
    await _disconnect();
  }

  // ── Client → Server methods ────────────────────────────────────────────────

  Future<void> moveCard({
    required String cardId,
    required String toColumnId,
    required int newOrder,
  }) async {
    if (!isConnected) throw StateError('Hub not connected.');
    await _connection!.invoke(
      'MoveCard',
      args: [cardId, toColumnId, newOrder],
    );
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _registerHandlers() {
    final conn = _connection!;

    conn.on('CardMoved', (List<Object?>? args) {
      if (args == null || args.length < 4) return;
      _cardMovedCtrl.add(CardMovedEvent(
        cardId: args[0]?.toString() ?? '',
        fromColumnId: args[1]?.toString() ?? '',
        toColumnId: args[2]?.toString() ?? '',
        newOrder: _toInt(args[3]),
      ));
    });

    conn.on('UserJoined', (List<Object?>? args) {
      if (args == null || args.length < 3) return;
      _userJoinedCtrl.add(UserPresenceEvent(
        userId: args[0]?.toString() ?? '',
        userName: args[1]?.toString(),
        boardId: args[2]?.toString() ?? '',
      ));
    });

    conn.on('UserLeft', (List<Object?>? args) {
      if (args == null || args.length < 2) return;
      _userLeftCtrl.add(UserPresenceEvent(
        userId: args[0]?.toString() ?? '',
        boardId: args[1]?.toString() ?? '',
      ));
    });

    conn.on('CommentAdded', (List<Object?>? args) {
      if (args == null || args.length < 2) return;
      // args[0] = taskCardId (Guid), args[1] = CommentDto object
      final taskCardId = args[0]?.toString() ?? '';
      final dto = args[1];
      if (dto == null) return;

      final map = _toMap(dto);
      if (map == null) return;

      _commentAddedCtrl.add(CommentAddedEvent(
        taskCardId: taskCardId,
        id: map['id']?.toString() ?? '',
        authorName: map['authorName']?.toString() ?? '',
        body: map['body']?.toString() ?? '',
        createdAt: map['createdAt']?.toString() ?? '',
        boardId: map['boardId']?.toString() ?? '',
        authorId: map['authorId']?.toString() ?? '',
      ));
    });
  }

  Future<void> _disconnect() async {
    await _connection?.stop();
    _connection = null;
    _activeBoardId = null;
  }

  List<OnlineUserEntity> _parseOnlineUsers(Object? raw) {
    if (raw == null) return [];
    if (raw is! List) return [];
    return raw
        .whereType<Map<Object?, Object?>>()
        .map((m) => OnlineUserEntity(
              userId: m['userId']?.toString() ?? '',
              userName: m['userName']?.toString() ?? '',
            ))
        .where((u) => u.userId.isNotEmpty)
        .toList();
  }

  Map<Object?, Object?>? _toMap(Object? v) {
    if (v is Map<Object?, Object?>) return v;
    return null;
  }

  int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  Future<void> dispose() async {
    await _disconnect();
    await _cardMovedCtrl.close();
    await _userJoinedCtrl.close();
    await _userLeftCtrl.close();
    await _commentAddedCtrl.close();
  }
}
