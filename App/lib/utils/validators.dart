/// Validators for the shared message contract.
///
/// Every inbound WebSocket message is parsed through these functions.
/// On invalid data they throw [ValidationException] — never silently accept
/// malformed messages.

import '../models/agent_message.dart';
import '../models/preflight_map.dart';
import '../models/session_status.dart';

// ---------------------------------------------------------------------------
// Exception
// ---------------------------------------------------------------------------

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

// ---------------------------------------------------------------------------
// Top-level parsers
// ---------------------------------------------------------------------------

/// Parse and validate an inbound raw JSON map into a typed [AgentMessage].
/// Throws [ValidationException] if any required field is missing or has wrong type.
AgentMessage parseAgentMessage(Map<String, dynamic> json) {
  final typeStr = json['type'] as String?;
  if (typeStr == null) throw const ValidationException('Missing field: type');

  final type = messageTypeFromWire(typeStr);
  if (type == null) throw ValidationException('Unknown MessageType: $typeStr');

  final sessionId = _requireString(json, 'sessionId');
  final projectId = _requireString(json, 'projectId');
  final deviceId = _requireString(json, 'deviceId');
  final timestamp = _requireString(json, 'timestamp');
  final payload = json['payload'] as Map<String, dynamic>? ?? {};

  return AgentMessage(
    type: type,
    sessionId: sessionId,
    projectId: projectId,
    deviceId: deviceId,
    timestamp: timestamp,
    payload: payload,
  );
}

PreflightMapPayload parsePreflightMapPayload(Map<String, dynamic> json) {
  final map = json['map'] as Map<String, dynamic>?;
  if (map == null) throw const ValidationException('Missing field: map');
  return PreflightMapPayload(
    map: parsePreflightMap(map),
    awaitingResponseId: _requireString(json, 'awaitingResponseId'),
  );
}

PreflightMap parsePreflightMap(Map<String, dynamic> json) {
  return PreflightMap(
    taskDescription: _requireString(json, 'taskDescription'),
    filesToRead: _requireStringList(json, 'filesToRead'),
    filesToWrite: _requireStringList(json, 'filesToWrite'),
    filesToDelete: _requireStringList(json, 'filesToDelete'),
    shellCommandsToRun: _requireStringList(json, 'shellCommandsToRun'),
    estimatedBlastRadius:
        _requireEnum(json, 'estimatedBlastRadius', BlastRadius.values),
    affectedFunctions: _requireStringList(json, 'affectedFunctions'),
    affectedModules: _requireStringList(json, 'affectedModules'),
    reasoning: _requireString(json, 'reasoning'),
  );
}

AwaitingApprovalPayload parseAwaitingApprovalPayload(
    Map<String, dynamic> json) {
  return AwaitingApprovalPayload(
    question: _requireString(json, 'question'),
    options: (json['options'] as List?)?.cast<String>(),
    awaitingResponseId: _requireString(json, 'awaitingResponseId'),
    timeoutMs: json['timeoutMs'] as int?,
  );
}

AgentLogPayload parseAgentLogPayload(Map<String, dynamic> json) {
  return AgentLogPayload(
    level: _requireEnum(json, 'level', AgentLogLevel.values),
    message: _requireString(json, 'message'),
    toolName: json['toolName'] as String?,
  );
}

TaskCompletePayload parseTaskCompletePayload(Map<String, dynamic> json) {
  return TaskCompletePayload(
    summary: _requireString(json, 'summary'),
    decisionsRecorded: json['decisionsRecorded'] as int? ?? 0,
    filesChanged: _requireStringList(json, 'filesChanged'),
    durationMs: json['durationMs'] as int? ?? 0,
  );
}

TaskFailedPayload parseTaskFailedPayload(Map<String, dynamic> json) {
  return TaskFailedPayload(
    error: _requireString(json, 'error'),
    partialCompletionSummary:
        json['partialCompletionSummary'] as String? ?? '',
    filesChanged:
        (json['filesChanged'] as List?)?.cast<String>() ?? const [],
  );
}

SessionStatusPayload parseSessionStatusPayload(Map<String, dynamic> json) {
  final level = json['dependenceLevel'] as int?;
  if (level == null || level < 1 || level > 5) {
    throw const ValidationException('dependenceLevel must be int 1–5');
  }
  return SessionStatusPayload(
    status: _requireEnum(json, 'status', SessionStatus.values),
    currentTask: json['currentTask'] as String?,
    dependenceLevel: level,
    remoteConnected: json['remoteConnected'] as bool? ?? false,
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

String _requireString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! String) {
    throw ValidationException('Missing or invalid field: $key');
  }
  return v;
}

List<String> _requireStringList(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! List) {
    throw ValidationException('Missing or invalid list: $key');
  }
  return v.cast<String>();
}

T _requireEnum<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
) {
  final str = _requireString(json, key);
  final camel = _snakeToCamel(str);
  return values.firstWhere(
    (e) => e.name == camel,
    orElse: () =>
        throw ValidationException('Invalid enum value "$str" for $key'),
  );
}

/// Converts `snake_case` to `camelCase` for enum name matching.
String _snakeToCamel(String input) {
  final parts = input.split('_');
  if (parts.isEmpty) return input;
  return parts.first +
      parts
          .skip(1)
          .map((p) =>
              p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}')
          .join();
}
