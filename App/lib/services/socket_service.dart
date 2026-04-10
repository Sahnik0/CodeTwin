/// WebSocket channel wrapper for communicating with server.ts bridge.
///
/// Converts raw bridge events handling stdout/stderr and attempts to
/// parse JSON payload lines back into AgentMessages for the app.

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
  String _deviceId = '';
  
  final Map<MessageType, List<MessageHandler>> _handlers = {};
  final List<BridgeEventHandler> _bridgeHandlers = [];
  
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  String? _lastSignalingUrl;

  VoidCallback? onPaired;
  VoidCallback? onNoPair;
  VoidCallback? onDisconnected;
  VoidCallback? onConnected;

  String? _activeJobId;
  String? get activeJobId => _activeJobId;

  bool get isConnected => _channel != null;
  String get deviceId => _deviceId;

  void connect(String signalingUrl, String deviceId) {
    _lastSignalingUrl = signalingUrl;
    _deviceId = deviceId;
    disconnect();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(signalingUrl));
      
      _reconnectAttempts = 0;
      _startPingTimer();
      onConnected?.call();
      
      // Request a generic subscribe
      _channel!.sink.add(jsonEncode({'type': 'subscribe'}));

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
        onDone: () {
          _handleDisconnect();
        },
        onError: (error) {
          if (kDebugMode) debugPrint('[SocketService] Error: $error');
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleBridgeEvent(BridgeEvent event) {
    // Notify low-level bridge listeners
    for (final h in _bridgeHandlers) {
      h(event);
    }

    if (event.type == BridgeEventType.start || event.type == BridgeEventType.accepted) {
      _activeJobId = event.jobId ?? event.raw['job']?['id'];
    }

    // Attempt to transparently route CLI JSON output back to AgentMessages
    if ((event.type == BridgeEventType.stdout || event.type == BridgeEventType.stderr) && event.text != null) {
      final text = event.text!.trim();
      
      // If it looks like JSON from the agent, parse it
      if (text.startsWith('{') && text.endsWith('}')) {
        try {
          final decoded = jsonDecode(text);
          if (decoded is Map<String, dynamic> && decoded.containsKey('type')) {
            final msg = parseAgentMessage(decoded);
            final list = _handlers[msg.type];
            if (list != null) {
              for (final h in list) h(msg);
            }
          }
        } catch (_) {
          _routeRawLog(text, event.type == BridgeEventType.stderr);
        }
      } else {
        _routeRawLog(text, event.type == BridgeEventType.stderr);
      }
    }
  }

  void _routeRawLog(String text, bool isError) {
    if (text.trim().isEmpty) return;
    final msg = AgentMessage(
      type: MessageType.agentLog,
      sessionId: '',
      projectId: '',
      deviceId: _deviceId,
      timestamp: DateTime.now().toIso8601String(),
      payload: {
        'level': isError ? 'error' : 'info',
        'message': text,
      },
    );
    final list = _handlers[MessageType.agentLog];
    if (list != null) {
      for (final h in list) h(msg);
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

  void send(AgentMessage msg) {
    // Legacy support: encode legacy AgentMessage to active job stdin
    if (_channel == null || _activeJobId == null) {
      debugPrint('[SocketService] Cannot send legacy msg: no active job or socket');
      return;
    }
    
    sendInput(jsonEncode(msg.toJson()));
  }

  void sendBridgeCommand(Map<String, dynamic> cmd) {
    if (_channel == null) return;
    _channel!.sink.add(jsonEncode(cmd));
  }

  void sendInput(String text, {bool appendNewline = true}) {
    if (_activeJobId == null) return;
    sendBridgeCommand({
      'type': 'input',
      'jobId': _activeJobId,
      'text': text,
      'appendNewline': appendNewline,
    });
  }

  VoidCallback on(MessageType type, MessageHandler handler) {
    _handlers.putIfAbsent(type, () => []).add(handler);
    return () => _handlers[type]?.remove(handler);
  }

  VoidCallback onBridgeEvent(BridgeEventHandler handler) {
    _bridgeHandlers.add(handler);
    return () => _bridgeHandlers.remove(handler);
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      // Server.ts relies on HTTP/WS ping-pong invisibly, but we can send an empty object or ping to keepalive
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    if (_lastSignalingUrl == null) return;

    final delaySeconds = _backoffDelay(_reconnectAttempts);
    _reconnectAttempts++;

    debugPrint('[SocketService] Reconnecting in \${delaySeconds}s');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (_lastSignalingUrl != null) {
        connect(_lastSignalingUrl!, _deviceId);
      }
    });
  }

  int _backoffDelay(int attempt) {
    final delay = 1 << attempt;
    return delay > 60 ? 60 : delay;
  }
}
