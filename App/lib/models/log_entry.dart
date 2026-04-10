import 'session_status.dart';
import 'preflight_map.dart';

/// A single log line from the agent.
class LogEntry {
  final String id;
  final AgentLogLevel level;
  final String message;
  final String? toolName;
  final String timestamp;

  const LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.toolName,
    required this.timestamp,
  });
}

/// Queued pre-flight map awaiting user approval.
class PreflightItem {
  final String awaitingResponseId;
  final PreflightMap map;
  final String receivedAt;

  const PreflightItem({
    required this.awaitingResponseId,
    required this.map,
    required this.receivedAt,
  });
}

/// Queued decision question awaiting user response.
class DecisionItem {
  final String awaitingResponseId;
  final String question;
  final List<String>? options;
  final int? timeoutMs;
  final String receivedAt;

  const DecisionItem({
    required this.awaitingResponseId,
    required this.question,
    this.options,
    this.timeoutMs,
    required this.receivedAt,
  });
}
