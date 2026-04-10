/// Singleton socket.io client wrapper.
///
/// The rest of the app never creates sockets directly — everything
/// goes through this service.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/agent_message.dart';
import '../utils/validators.dart';

typedef MessageHandler = void Function(AgentMessage msg);

class SocketService {
  // ── singleton ────────────────────────────────────────────────────────────
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // ── private state ────────────────────────────────────────────────────────
  IO.Socket? _socket;
  String _deviceId = '';
  final Map<MessageType, List<MessageHandler>> _handlers = {};
  Timer? _pingTimer;

  // Reconnect backoff
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  String? _lastSignalingUrl;

  // Presence callbacks
  VoidCallback? onPaired;
  VoidCallback? onNoPair;
  VoidCallback? onDisconnected;
  VoidCallback? onConnected;

  // ── public API ───────────────────────────────────────────────────────────

  bool get isConnected => _socket?.connected ?? false;
  String get deviceId => _deviceId;

  void connect(String signalingUrl, String deviceId) {
    _lastSignalingUrl = signalingUrl;
    _deviceId = deviceId;

    // Tear down any existing socket
    disconnect();

    _socket = IO.io(
      signalingUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    // ── lifecycle events ─────────────────────────────────────────────────
    _socket!.onConnect((_) {
      debugPrint('[SocketService] Connected to $signalingUrl');
      _reconnectAttempts = 0;
      _socket!.emit('register', {'deviceId': deviceId, 'type': 'client'});
      _startPingTimer();
      onConnected?.call();
    });

    _socket!.on('message', (data) {
      if (data is! Map<String, dynamic>) return;
      try {
        final msg = parseAgentMessage(data);
        final list = _handlers[msg.type];
        if (list != null) {
          for (final h in list) {
            h(msg);
          }
        }
      } on ValidationException catch (e) {
        if (kDebugMode) debugPrint('[SocketService] Bad message: $e');
        // Release mode: silently discard
      }
    });

    _socket!.on('paired', (_) {
      debugPrint('[SocketService] Daemon paired');
      onPaired?.call();
    });

    _socket!.on('no_pair', (_) {
      debugPrint('[SocketService] No pair — daemon not online');
      onNoPair?.call();
    });

    _socket!.on('pong', (_) {
      // Keepalive acknowledged — reset reconnect timer
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SocketService] Disconnected');
      _stopPingTimer();
      onDisconnected?.call();
      _scheduleReconnect();
    });

    _socket!.onError((error) {
      debugPrint('[SocketService] Error: $error');
    });

    _socket!.connect();
  }

  void disconnect() {
    _stopPingTimer();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _socket?.dispose();
    _socket = null;
  }

  void send(AgentMessage msg) {
    if (_socket == null || !isConnected) {
      debugPrint('[SocketService] Cannot send — not connected');
      return;
    }
    _socket!.emit('message', msg.toJson());
  }

  /// Register a handler for a specific [MessageType].
  /// Returns an unsubscribe function.
  VoidCallback on(MessageType type, MessageHandler handler) {
    _handlers.putIfAbsent(type, () => []).add(handler);
    return () => _handlers[type]?.remove(handler);
  }

  // ── keepalive ──────────────────────────────────────────────────────────

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (isConnected) {
        _socket!.emit('ping');
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ── reconnect with exponential backoff ─────────────────────────────────

  void _scheduleReconnect() {
    if (_lastSignalingUrl == null) return;

    final delaySeconds = _backoffDelay(_reconnectAttempts);
    _reconnectAttempts++;

    debugPrint('[SocketService] Reconnecting in ${delaySeconds}s '
        '(attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_lastSignalingUrl != null) {
        connect(_lastSignalingUrl!, _deviceId);
      }
    });
  }

  /// 1s → 2s → 4s → 8s → … → max 60s
  int _backoffDelay(int attempt) {
    final delay = 1 << attempt; // 2^attempt
    return delay > 60 ? 60 : delay;
  }
}
