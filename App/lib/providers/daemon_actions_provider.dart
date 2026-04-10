/// Provider that exposes high-level actions for talking to the daemon.
///
/// All outbound messages go through [DaemonActions].

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_message.dart';
import '../providers/connection_provider.dart';
import '../providers/session_provider.dart';
import '../services/socket_service.dart';

class DaemonActions {
  final DaemonConnectionState connection;
  final SessionState session;
  final SocketService socketService;

  DaemonActions(this.connection, this.session, this.socketService);

  bool get isDaemonConnected => connection.daemonConnected;

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

  void submitTask(String task) => _send(MessageType.taskSubmit, {
        'task': task,
        'dependenceLevel': session.dependenceLevel,
      });

  void cancelTask() => _send(MessageType.taskCancel, {});

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
  final connection =
      ref.watch(connectionProvider).valueOrNull ?? DaemonConnectionState.empty;
  final session =
      ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
  return DaemonActions(connection, session, SocketService());
});
