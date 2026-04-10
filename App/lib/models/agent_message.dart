/// All WebSocket message types shared between the CLI daemon and the app.
///
/// This file is the Dart source-of-truth for the wire protocol.
/// Never add types here that don't exist on the CLI side.

enum MessageType {
  taskSubmit,
  taskCancel,
  preflightMap,
  awaitingApproval,
  userApprove,
  userReject,
  userAnswer,
  agentLog,
  taskComplete,
  taskFailed,
  sessionStatus,
  decisionQueued,
  twinUpdate,
  daemonOnline,
  daemonOffline,
  levelChange,
  ping,
  pong,
}

/// Wire-format string mapping (matches CLI exactly).
const messageTypeWireNames = <MessageType, String>{
  MessageType.taskSubmit: 'TASK_SUBMIT',
  MessageType.taskCancel: 'TASK_CANCEL',
  MessageType.preflightMap: 'PREFLIGHT_MAP',
  MessageType.awaitingApproval: 'AWAITING_APPROVAL',
  MessageType.userApprove: 'USER_APPROVE',
  MessageType.userReject: 'USER_REJECT',
  MessageType.userAnswer: 'USER_ANSWER',
  MessageType.agentLog: 'AGENT_LOG',
  MessageType.taskComplete: 'TASK_COMPLETE',
  MessageType.taskFailed: 'TASK_FAILED',
  MessageType.sessionStatus: 'SESSION_STATUS',
  MessageType.decisionQueued: 'DECISION_QUEUED',
  MessageType.twinUpdate: 'TWIN_UPDATE',
  MessageType.daemonOnline: 'DAEMON_ONLINE',
  MessageType.daemonOffline: 'DAEMON_OFFLINE',
  MessageType.levelChange: 'LEVEL_CHANGE',
  MessageType.ping: 'PING',
  MessageType.pong: 'PONG',
};

/// Reverse lookup: wire string → enum value. Returns `null` if unknown.
MessageType? messageTypeFromWire(String wire) {
  for (final entry in messageTypeWireNames.entries) {
    if (entry.value == wire) return entry.key;
  }
  return null;
}

/// Wire name for a given [MessageType].
String messageTypeToWire(MessageType type) =>
    messageTypeWireNames[type] ?? type.name;

// ---------------------------------------------------------------------------
// AgentMessage — envelope for every WebSocket message
// ---------------------------------------------------------------------------

class AgentMessage {
  final MessageType type;
  final String sessionId;
  final String projectId;
  final String deviceId;
  final String timestamp; // ISO 8601
  final Map<String, dynamic> payload;

  const AgentMessage({
    required this.type,
    required this.sessionId,
    required this.projectId,
    required this.deviceId,
    required this.timestamp,
    required this.payload,
  });

  factory AgentMessage.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String?;
    final type = typeStr != null ? messageTypeFromWire(typeStr) : null;
    return AgentMessage(
      type: type ?? MessageType.ping,
      sessionId: json['sessionId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'type': messageTypeToWire(type),
        'sessionId': sessionId,
        'projectId': projectId,
        'deviceId': deviceId,
        'timestamp': timestamp,
        'payload': payload,
      };
}
