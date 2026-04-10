/// WebSocket channel wrapper for the CodeTwin remote bridge.
///
/// Connects to the Render-hosted bridge server (wsUrl) with the
/// clientToken from pairing, then routes incoming bridge events to
/// both low-level BridgeEventHandlers and higher-level AgentMessage
/// handlers (by parsing JSON from stdout/stderr lines).

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/agent_message.dart';
import '../models/bridge_event.dart';
import '../utils/validators.dart';

typedef MessageHandler = void Function(AgentMessage msg);
typedef BridgeEventHandler = void Function(BridgeEvent event);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocketChannel? _channel;
  String _mobileDeviceId = '';

  final Map<MessageType, List<MessageHandler>> _handlers = {};
  final List<BridgeEventHandler> _bridgeHandlers = [];

  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _lastWsUrl;
  String? _lastToken;

  VoidCallback? onPaired;
  VoidCallback? onNoPair;
  VoidCallback? onDisconnected;
  VoidCallback? onConnected;

  String? _activeJobId;
  String? get activeJobId => _activeJobId;

  bool get isConnected => _channel != null;
  String get deviceId => _mobileDeviceId;

  /// Connect to the bridge WebSocket using the clientToken for auth.
  ///
  /// Preferred: passes token as [Authorization: Bearer] header.
  /// Fallback: appends [?token=<clientToken>] query parameter.
  void connect(String wsUrl, String clientToken, {String mobileDeviceId = '', bool isReconnect = false}) {
    _lastWsUrl = wsUrl;
    _lastToken = clientToken;
    _mobileDeviceId = mobileDeviceId;
    disconnect();

    // Only reset the backoff counter on fresh manual connections,
    // not on internal reconnect scheduling (so backoff actually grows).
    if (!isReconnect) _reconnectAttempts = 0;

    try {
      final uri = _buildUri(wsUrl, clientToken);
      if (kDebugMode) debugPrint('[SocketService] Connecting to $uri');

      _channel = WebSocketChannel.connect(uri);
      _startPingTimer();

      // Request subscription immediately after connecting
      _channel!.stream.listen(
        (message) {
          if (message is! String) return;
          try {
            final decoded = jsonDecode(message);
            if (decoded is! Map<String, dynamic>) return;
            final event = BridgeEvent.fromJson(decoded);
            _handleBridgeEvent(event);
          } catch (e) {
            if (kDebugMode) debugPrint('[SocketService] Parse error: $e');
          }
        },
        onDone: () => _handleDisconnect(),
        onError: (error) {
          if (kDebugMode) debugPrint('[SocketService] Error: $error');
          _handleDisconnect();
        },
      );

      // Wait for 'ready' event from server before sending subscribe
      // (handled in _handleBridgeEvent → BridgeEventType.ready)
    } catch (e) {
      if (kDebugMode) debugPrint('[SocketService] Connect failed: $e');
      _handleDisconnect();
    }
  }

  Uri _buildUri(String wsUrl, String token) {
    final base = Uri.parse(wsUrl);
    // Append token as query param
    final params = Map<String, String>.from(base.queryParameters)
      ..['token'] = token;
    return base.replace(queryParameters: params);
  }

  void _handleBridgeEvent(BridgeEvent event) {
    // Notify all registered low-level handlers
    for (final h in List.of(_bridgeHandlers)) {
      h(event);
    }

    switch (event.type) {
      case BridgeEventType.ready:
        // Server is ready — subscribe to all events for this pairing
        if (kDebugMode) debugPrint('[SocketService] Server ready, subscribing');
        _channel?.sink.add(jsonEncode({'type': 'subscribe'}));
        onConnected?.call();

      case BridgeEventType.subscribed:
        if (kDebugMode) debugPrint('[SocketService] Subscribed to bridge');

      case BridgeEventType.accepted:
        // A job was accepted; track the active job ID
        _activeJobId = event.jobId ?? event.raw['job']?['id'] as String?;
        if (kDebugMode) debugPrint('[SocketService] Job accepted: $_activeJobId');

      case BridgeEventType.start:
        _activeJobId ??= event.jobId ?? event.raw['job']?['id'] as String?;
        if (kDebugMode) debugPrint('[SocketService] Job started: $_activeJobId');

      case BridgeEventType.exit:
        if (kDebugMode) {
          debugPrint('[SocketService] Job exit code: ${event.exitCode}');
        }
        // Keep activeJobId so user can still query logs; clear on next execute

      case BridgeEventType.error:
        if (kDebugMode) {
          debugPrint('[SocketService] Bridge error: ${event.message}');
        }

      default:
        break;
    }

    // Parse stdout/stderr for AgentMessage JSON (CLI agent output)
    if ((event.type == BridgeEventType.stdout ||
            event.type == BridgeEventType.stderr) &&
        event.text != null) {
      _routeOutput(event.text!.trim(), event.type == BridgeEventType.stderr);
    }
  }

  void _routeOutput(String text, bool isError) {
    if (text.isEmpty) return;

    // Try to parse as an AgentMessage JSON envelope
    if (text.startsWith('{') && text.endsWith('}')) {
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic> && decoded.containsKey('type')) {
          final msg = parseAgentMessage(decoded);
          final list = _handlers[msg.type];
          if (list != null) {
            for (final h in List.of(list)) h(msg);
          }
          return;
        }
      } catch (_) {
        // Not a valid AgentMessage — fall through to raw log
      }
    }

    _routeRawLog(text, isError);
  }

  void _routeRawLog(String text, bool isError) {
    if (text.trim().isEmpty) return;
    final msg = AgentMessage(
      type: MessageType.agentLog,
      sessionId: '',
      projectId: '',
      deviceId: _mobileDeviceId,
      timestamp: DateTime.now().toIso8601String(),
      payload: {
        'level': isError ? 'error' : 'info',
        'message': text,
      },
    );
    final list = _handlers[MessageType.agentLog];
    if (list != null) {
      for (final h in List.of(list)) h(msg);
    }
  }

  void _handleDisconnect() {
    if (kDebugMode) debugPrint('[SocketService] Disconnected');
    _stopPingTimer();
    _channel = null;
    onDisconnected?.call();
    _scheduleReconnect();
  }

  void disconnect() {
    _stopPingTimer();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _channel?.sink.close();
    _channel = null;
  }

  /// Send a raw bridge command JSON object.
  void sendBridgeCommand(Map<String, dynamic> cmd) {
    if (_channel == null) {
      if (kDebugMode) debugPrint('[SocketService] Cannot send: not connected');
      return;
    }
    _channel!.sink.add(jsonEncode(cmd));
  }

  /// Send text input to the active job's stdin.
  void sendInput(String text, {bool appendNewline = true}) {
    if (_activeJobId == null) {
      if (kDebugMode) debugPrint('[SocketService] No active job for input');
      return;
    }
    sendBridgeCommand({
      'type': 'input',
      'jobId': _activeJobId,
      'text': text,
      'appendNewline': appendNewline,
    });
  }

  /// Legacy helper — encode an AgentMessage and send as stdin to active job.
  void send(AgentMessage msg) {
    if (_channel == null || _activeJobId == null) {
      debugPrint('[SocketService] Cannot send legacy msg: no active job or socket');
      return;
    }
    sendInput(jsonEncode(msg.toJson()));
  }

  /// Subscribe to a specific job's events (or all if jobId is null).
  void subscribeToJob(String? jobId) {
    sendBridgeCommand({
      'type': 'subscribe',
      if (jobId != null) 'jobId': jobId,
    });
  }

  // ── Handler registration ─────────────────────────────────────────────────

  VoidCallback on(MessageType type, MessageHandler handler) {
    _handlers.putIfAbsent(type, () => []).add(handler);
    return () => _handlers[type]?.remove(handler);
  }

  VoidCallback onBridgeEvent(BridgeEventHandler handler) {
    _bridgeHandlers.add(handler);
    return () => _bridgeHandlers.remove(handler);
  }

  // ── Ping / Reconnect ─────────────────────────────────────────────────────

  void _startPingTimer() {
    _stopPingTimer();
    // Send a JSON ping every 20s to keep the Render WebSocket connection alive.
    // Render's free tier closes idle WS connections after ~30s of no traffic.
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping', 'ts': DateTime.now().millisecondsSinceEpoch}));
          if (kDebugMode) debugPrint('[SocketService] Ping sent');
        } catch (e) {
          if (kDebugMode) debugPrint('[SocketService] Ping failed: $e');
        }
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    if (_lastWsUrl == null || _lastToken == null) return;

    final delaySeconds = _backoffDelay(_reconnectAttempts);
    _reconnectAttempts++;

    if (kDebugMode) {
      debugPrint('[SocketService] Reconnecting in ${delaySeconds}s '
          '(attempt $_reconnectAttempts)');
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_lastWsUrl != null && _lastToken != null) {
        connect(_lastWsUrl!, _lastToken!, mobileDeviceId: _mobileDeviceId, isReconnect: true);
      }
    });
  }

  /// Exponential backoff capped at 30s per spec.
  int _backoffDelay(int attempt) {
    final delay = 1 << attempt; // 1, 2, 4, 8, 16, 32 ...
    return delay > 30 ? 30 : delay;
  }
}
