/// Dispatches validated inbound messages to the correct provider notifier.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/agent_message.dart';
import '../models/log_entry.dart';
import '../providers/session_provider.dart';
import '../providers/connection_provider.dart';
import '../services/notifications_service.dart';
import '../utils/validators.dart';

const _uuid = Uuid();

class MessageService {
  final Ref ref;
  const MessageService(this.ref);

  void handleInboundMessage(AgentMessage msg) {
    try {
      switch (msg.type) {
        case MessageType.agentLog:
          _handleAgentLog(msg);
        case MessageType.preflightMap:
          _handlePreflightMap(msg);
        case MessageType.awaitingApproval:
          _handleAwaitingApproval(msg);
        case MessageType.taskComplete:
          _handleTaskComplete(msg);
        case MessageType.taskFailed:
          _handleTaskFailed(msg);
        case MessageType.sessionStatus:
          _handleSessionStatus(msg);
        case MessageType.decisionQueued:
          _handleDecisionQueued(msg);
        case MessageType.twinUpdate:
          debugPrint('[MessageService] Twin updated');
        case MessageType.daemonOnline:
          ref.read(connectionProvider.notifier).setDaemonConnected(true);
        case MessageType.daemonOffline:
          ref.read(connectionProvider.notifier).setDaemonConnected(false);
        case MessageType.pong:
          ref
              .read(connectionProvider.notifier)
              .setLastPongAt(DateTime.now().toIso8601String());
        default:
          break;
      }
    } on ValidationException catch (e) {
      if (kDebugMode) debugPrint('[MessageService] Validation error: $e');
    }
  }

  // ── handlers ──────────────────────────────────────────────────────────

  void _handleAgentLog(AgentMessage msg) {
    final payload = parseAgentLogPayload(msg.payload);
    final entry = LogEntry(
      id: _uuid.v4(),
      level: payload.level,
      message: payload.message,
      toolName: payload.toolName,
      timestamp: msg.timestamp,
    );
    ref.read(sessionProvider.notifier).appendLog(entry);
  }

  void _handlePreflightMap(AgentMessage msg) {
    final payload = parsePreflightMapPayload(msg.payload);
    final item = PreflightItem(
      awaitingResponseId: payload.awaitingResponseId,
      map: payload.map,
      receivedAt: msg.timestamp,
    );
    ref.read(sessionProvider.notifier).pushPreflight(item);

    // Trigger notification
    NotificationsService().showPreflightNotification(
      payload.map.taskDescription,
      payload.map.estimatedBlastRadius.name,
    );
  }

  void _handleAwaitingApproval(AgentMessage msg) {
    final payload = parseAwaitingApprovalPayload(msg.payload);
    final item = DecisionItem(
      awaitingResponseId: payload.awaitingResponseId,
      question: payload.question,
      options: payload.options,
      timeoutMs: payload.timeoutMs,
      receivedAt: msg.timestamp,
    );
    ref.read(sessionProvider.notifier).pushDecision(item);

    // Trigger notification
    NotificationsService().showApprovalNotification(
      payload.question,
      payload.awaitingResponseId,
    );
  }

  void _handleTaskComplete(AgentMessage msg) {
    final payload = parseTaskCompletePayload(msg.payload);
    ref.read(sessionProvider.notifier).setLastComplete(payload);

    NotificationsService().showCompleteNotification(payload.summary);
  }

  void _handleTaskFailed(AgentMessage msg) {
    final payload = parseTaskFailedPayload(msg.payload);
    ref.read(sessionProvider.notifier).setLastFailed(payload);

    NotificationsService().showFailedNotification(payload.error);
  }

  void _handleSessionStatus(AgentMessage msg) {
    final payload = parseSessionStatusPayload(msg.payload);
    final notifier = ref.read(sessionProvider.notifier);
    notifier.syncFromStatus(payload);
    notifier.setSession(msg.sessionId, msg.projectId);
  }

  void _handleDecisionQueued(AgentMessage msg) {
    // The daemon queues decisions in delegation mode — show badge count
    // by pushing a placeholder decision item
    debugPrint('[MessageService] Decision queued (delegation mode)');
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService(ref);
});
