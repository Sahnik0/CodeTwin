/// Pure Riverpod provider that wires SocketService events to ConnectionProvider.
///
/// Watch this provider once in app.dart or a top-level widget to activate it.
/// Being a provider (not a widget) avoids GlobalKey conflicts from wrapping
/// the Go Router StatefulNavigationShell in a StatefulWidget.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../models/bridge_event.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../providers/connection_provider.dart';
import '../providers/session_provider.dart';

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

String? _asString(dynamic value) {
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return null;
}

String _describeCliError(dynamic error) {
  if (error is String && error.trim().isNotEmpty) return error.trim();
  final map = _asMap(error);
  if (map == null) return 'CLI runtime error';

  final direct = _asString(map['message']);
  if (direct != null) return direct;

  final data = _asMap(map['data']);
  final nested = data == null ? null : _asString(data['message']);
  if (nested != null) return nested;

  final name = _asString(map['name']) ?? 'CLI runtime error';
  return name;
}

void _appendLog(
  SessionNotifier sessionNotifier, {
  required AgentLogLevel level,
  required String message,
  String? toolName,
  LogSource source = LogSource.structured,
  String? structuredType,
}) {
  sessionNotifier.appendLog(
    LogEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      level: level,
      message: message,
      toolName: toolName,
      timestamp: DateTime.now().toIso8601String(),
      source: source,
      structuredType: structuredType,
    ),
  );
}

String _stepFinishSummary(Map<String, dynamic>? part) {
  if (part == null) return 'Step completed';
  final reason = _asString(part['reason']);
  final tokens = _asMap(part['tokens']);
  final output = tokens == null ? null : tokens['output'];
  final suffix = output is num ? ' · output tokens: $output' : '';
  if (reason != null) return 'Step completed ($reason)$suffix';
  return 'Step completed$suffix';
}

void _handleCliEvent(
  BridgeEvent event,
  SessionNotifier sessionNotifier,
) {
  final payload = event.cliEvent;
  if (payload == null) return;

  final type = payload['type'] as String?;
  if (type == null) return;

  switch (type) {
    case 'text':
      final part = _asMap(payload['part']);
      final text = part == null ? null : _asString(part['text']);
      if (text != null) {
        _appendLog(
          sessionNotifier,
          level: AgentLogLevel.info,
          message: text,
          source: LogSource.structured,
          structuredType: type,
        );
      }
      break;

    case 'reasoning':
      final part = _asMap(payload['part']);
      final text = part == null ? null : _asString(part['text']);
      if (text != null) {
        _appendLog(
          sessionNotifier,
          level: AgentLogLevel.info,
          message: 'Thinking: $text',
          source: LogSource.structured,
          structuredType: type,
        );
      }
      break;

    case 'tool_use':
      final part = _asMap(payload['part']);
      final state = part == null ? null : _asMap(part['state']);
      final tool = part == null ? null : _asString(part['tool']);
      final status = state == null ? null : _asString(state['status']);

      final toolName = tool ?? 'Tool';
      if (status == 'error') {
        final error = _asString(state?['error']) ?? 'Tool failed';
        _appendLog(
          sessionNotifier,
          level: AgentLogLevel.error,
          message: '$toolName failed: $error',
          toolName: toolName,
          source: LogSource.structured,
          structuredType: type,
        );
      } else {
        final label = status == null ? 'updated' : status;
        _appendLog(
          sessionNotifier,
          level: AgentLogLevel.tool,
          message: '$toolName $label',
          toolName: toolName,
          source: LogSource.structured,
          structuredType: type,
        );
      }
      break;

    case 'step_start':
      _appendLog(
        sessionNotifier,
        level: AgentLogLevel.info,
        message: 'Step started',
        source: LogSource.structured,
        structuredType: type,
      );
      break;

    case 'step_finish':
      _appendLog(
        sessionNotifier,
        level: AgentLogLevel.info,
        message: _stepFinishSummary(_asMap(payload['part'])),
        source: LogSource.structured,
        structuredType: type,
      );
      break;

    case 'error':
      _appendLog(
        sessionNotifier,
        level: AgentLogLevel.error,
        message: _describeCliError(payload['error']),
        source: LogSource.structured,
        structuredType: type,
      );
      sessionNotifier.setStatus(SessionStatus.failed);
      break;

    default:
      break;
  }
}

final bridgeListenerProvider = Provider.autoDispose<void>((ref) {
  // Keep this provider alive for the full app session so callbacks
  // are never torn down by an intermediate rebuild.
  ref.keepAlive();

  final socket = SocketService();

  socket.onConnected = () {
    if (kDebugMode) debugPrint('[BridgeListener] WS connected → online');
    ref.read(connectionProvider.notifier)
      ..setAppConnected(true)
      ..setDaemonConnected(true);
  };

  socket.onDisconnected = () {
    if (kDebugMode) debugPrint('[BridgeListener] WS disconnected');
    ref.read(connectionProvider.notifier)
      ..setAppConnected(false)
      ..setDaemonConnected(false);
  };

  final cancelBridgeListener = socket.onBridgeEvent((event) {
    final connNotifier = ref.read(connectionProvider.notifier);
    final sessionNotifier = ref.read(sessionProvider.notifier);
    switch (event.type) {
      case BridgeEventType.ready:
      case BridgeEventType.subscribed:
        connNotifier
          ..setAppConnected(true)
          ..setDaemonConnected(true);
        break;

      case BridgeEventType.accepted:
        final job = _asMap(event.raw['job']);
        final command = job == null ? null : _asString(job['command']);
        if (command != null) {
          sessionNotifier.setCurrentTask(command);
        }
        sessionNotifier.setStatus(SessionStatus.running);
        break;

      case BridgeEventType.start:
        final args = event.raw['args'];
        if (args is List && args.length >= 2 && args.first == 'run') {
          final runPrompt = _asString(args[1]);
          if (runPrompt != null) sessionNotifier.setCurrentTask(runPrompt);
        }
        sessionNotifier.setStatus(SessionStatus.running);
        break;

      case BridgeEventType.cliEvent:
        _handleCliEvent(event, sessionNotifier);
        break;

      case BridgeEventType.stdout:
      case BridgeEventType.stderr:
        final text = event.text ?? '';
        if (text.isNotEmpty) {
          _appendLog(
            sessionNotifier,
            level:
                event.type == BridgeEventType.stderr
                    ? AgentLogLevel.error
                    : AgentLogLevel.info,
            message: text,
            source: LogSource.raw,
          );
        }
        break;

      case BridgeEventType.exit:
        final code = event.exitCode;
        if (code == null || code == 0) {
          sessionNotifier.setStatus(SessionStatus.idle);
        } else {
          sessionNotifier.setStatus(SessionStatus.failed);
        }
        sessionNotifier.setCurrentTask(null);
        connNotifier.setLastPongAt(DateTime.now().toIso8601String());
        break;

      case BridgeEventType.error:
        final msg = event.message ?? '';
        if (kDebugMode) debugPrint('[BridgeListener] Bridge error: $msg');
        if (msg.contains('401') ||
            msg.contains('Unauthorized') ||
            msg.contains('expired')) {
          connNotifier.markTokenExpired();
        }
        _appendLog(
          sessionNotifier,
          level: AgentLogLevel.error,
          message: msg.isEmpty ? 'Bridge error' : msg,
          source: LogSource.raw,
        );
        final benign =
            msg.contains('Job not found') ||
            msg.contains('Unsupported message type');
        if (!benign) {
          sessionNotifier.setStatus(SessionStatus.failed);
        }
        break;

      case BridgeEventType.pong:
        connNotifier.setLastPongAt(DateTime.now().toIso8601String());
        break;

      default:
        break;
    }
  });

  // Sync immediately if already connected — deferred so Riverpod finishes
  // building this provider before we mutate connectionProvider.
  if (socket.isConnected) {
    Future.microtask(() {
      ref.read(connectionProvider.notifier)
        ..setAppConnected(true)
        ..setDaemonConnected(true);
    });
  }

  ref.onDispose(() {
    cancelBridgeListener();
    socket.onConnected = null;
    socket.onDisconnected = null;
  });
});
