/// Provider that exposes high-level actions for talking to the daemon.
///
/// All outbound messages go through [DaemonActions].

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_message.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../providers/connection_provider.dart';
import '../providers/session_provider.dart';
import '../services/socket_service.dart';

class DaemonActions {
  final SocketService socketService;
  final Ref ref;

  DaemonActions(this.socketService, this.ref);

  DaemonConnectionState get connection =>
      ref.read(connectionProvider).valueOrNull ?? DaemonConnectionState.empty;

  SessionState get session =>
      ref.read(sessionProvider).valueOrNull ?? SessionState.empty;

  // Check the live WS channel, not the provider flag which can lag behind
  // reconnect cycles. This ensures submitTask works as soon as the WS is open.
  bool get isDaemonConnected => socketService.isConnected;

  // ── internal ─────────────────────────────────────────────────────────────

  void _send(MessageType type, Map<String, dynamic> payload) {
    if (!isDaemonConnected) {
      debugPrint('[DaemonActions] Daemon offline — cannot send $type');
      return;
    }
    final msg = AgentMessage(
      type: type,
      sessionId: session.sessionId ?? '',
      projectId: session.projectId ?? '',
      deviceId: connection.deviceId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      payload: payload,
    );
    socketService.send(msg);
  }

  // ── public API ───────────────────────────────────────────────────────────

  void submitTask(String task) {
    // ── verbose debug trace ──────────────────────────────────────────────────
    debugPrint('[DaemonActions] submitTask called: "$task"');
    debugPrint('[DaemonActions] isConnected=${socketService.isConnected}');
    debugPrint('[DaemonActions] activeJobId=${socketService.activeJobId}');
    // ────────────────────────────────────────────────────────────────────────

    ref.read(sessionProvider.notifier).appendLog(LogEntry(
          id: 'user_input_${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now().toIso8601String(),
          level: AgentLogLevel.info,
          message: '> Task: $task',
        ));

    if (!isDaemonConnected) {
      debugPrint('[DaemonActions] BLOCKED — daemon offline');
      ref.read(sessionProvider.notifier).appendLog(LogEntry(
            id: 'err_${DateTime.now().millisecondsSinceEpoch}',
            timestamp: DateTime.now().toIso8601String(),
            level: AgentLogLevel.error,
            message: 'Failed to send task: Agent disconnected. Please connect the CLI daemon first.',
          ));
      return;
    }
    debugPrint('[DaemonActions] SENDING cliExecute to bridge...');
    socketService.sendBridgeCommand({
      'type': 'cliExecute',
      'args': [
        'run',
        task,
        '--dangerously-skip-permissions',
        '--dependence-level',
        session.dependenceLevel.toString(),
      ],
      'env': {'CODETWIN_DEPENDENCE_LEVEL': session.dependenceLevel.toString()},
    });
    
    // Immediately display 'running' rather than waiting for stdout, improving perceived latency.
    ref.read(sessionProvider.notifier).setStatus(SessionStatus.running);
    ref.read(sessionProvider.notifier).setCurrentTask('Initializing agent...');
    
    debugPrint('[DaemonActions] cliExecute sent ✓');
  }

  void cancelTask() {
    if (socketService.activeJobId != null) {
      socketService.sendBridgeCommand({
        'type': 'terminate',
        'jobId': socketService.activeJobId,
        'signal': 'SIGTERM',
      });
    }
  }

  void approve(String awaitingResponseId) => _send(
        MessageType.userApprove,
        {'awaitingResponseId': awaitingResponseId},
      );

  void reject(String awaitingResponseId) => _send(
        MessageType.userReject,
        {'awaitingResponseId': awaitingResponseId},
      );

  void answer(String awaitingResponseId, String answer) => _send(
        MessageType.userAnswer,
        {'awaitingResponseId': awaitingResponseId, 'answer': answer},
      );

  void changeLevel(int newLevel) =>
      _send(MessageType.levelChange, {'newLevel': newLevel});

  void ping() => _send(MessageType.ping, {});
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final daemonActionsProvider = Provider<DaemonActions>((ref) {
  return DaemonActions(SocketService(), ref);
});
