import 'dart:async';

import 'package:signalr_netcore/signalr_netcore.dart';

import '../../../../core/storage/secure_storage_service.dart';

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

// ── Service ───────────────────────────────────────────────────────────────────

/// Manages the SignalR connection to /hubs/board.
/// Call [connect] when entering a board, [disconnect] when leaving.
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

  Stream<CardMovedEvent> get cardMoved => _cardMovedCtrl.stream;
  Stream<UserPresenceEvent> get userJoined => _userJoinedCtrl.stream;
  Stream<UserPresenceEvent> get userLeft => _userLeftCtrl.stream;

  /// Whether the hub connection is currently established.
  bool get isConnected =>
      _connection?.state == HubConnectionState.Connected;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  /// Establishes a hub connection and joins [boardId]'s group.
  Future<void> connect(String boardId) async {
    if (_connection?.state == HubConnectionState.Connected &&
        _activeBoardId == boardId) return;

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
    await _connection!.invoke('JoinBoard', args: [boardId]);
    _activeBoardId = boardId;
  }

  /// Leaves the board group and closes the connection.
  Future<void> disconnect(String boardId) async {
    if (_connection?.state == HubConnectionState.Connected) {
      try {
        await _connection!.invoke('LeaveBoard', args: [boardId]);
      } catch (_) {
        // Best-effort leave; connection may already be closing.
      }
    }
    await _disconnect();
  }

  // ── Client → Server methods ────────────────────────────────────────────────

  /// Sends a card move through the hub. The server processes the command and
  /// broadcasts [CardMoved] to all board group members (including the caller).
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
  }

  Future<void> _disconnect() async {
    await _connection?.stop();
    _connection = null;
    _activeBoardId = null;
  }

  int _toInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  /// Closes the stream controllers. Call only when the service itself is disposed.
  Future<void> dispose() async {
    await _disconnect();
    await _cardMovedCtrl.close();
    await _userJoinedCtrl.close();
    await _userLeftCtrl.close();
  }
}
