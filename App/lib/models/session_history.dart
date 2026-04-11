import 'session_status.dart';

enum SessionRunOutcome { completed, failed }

class SessionHistoryMessage {
  final String id;
  final String timestamp;
  final bool isUser;
  final String message;
  final AgentLogLevel level;
  final String? structuredType;

  const SessionHistoryMessage({
    required this.id,
    required this.timestamp,
    required this.isUser,
    required this.message,
    required this.level,
    this.structuredType,
  });

  factory SessionHistoryMessage.fromJson(Map<String, dynamic> json) {
    final levelIndex = json['level'] is int ? json['level'] as int : 0;
    final safeLevelIndex = levelIndex.clamp(0, AgentLogLevel.values.length - 1);
    return SessionHistoryMessage(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      isUser: json['isUser'] == true,
      message: json['message'] as String? ?? '',
      level: AgentLogLevel.values[safeLevelIndex],
      structuredType: json['structuredType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp,
    'isUser': isUser,
    'message': message,
    'level': level.index,
    'structuredType': structuredType,
  };
}

class SessionHistoryItem {
  final String id;
  final String? sessionId;
  final String? projectId;
  final String task;
  final String startedAt;
  final String endedAt;
  final SessionRunOutcome outcome;
  final String resultSummary;
  final List<String> filesChanged;
  final int? durationMs;
  final List<SessionHistoryMessage> messages;

  const SessionHistoryItem({
    required this.id,
    this.sessionId,
    this.projectId,
    required this.task,
    required this.startedAt,
    required this.endedAt,
    required this.outcome,
    required this.resultSummary,
    this.filesChanged = const [],
    this.durationMs,
    this.messages = const [],
  });

  factory SessionHistoryItem.fromJson(Map<String, dynamic> json) {
    final outcomeIndex = json['outcome'] is int ? json['outcome'] as int : 0;
    final safeOutcomeIndex = outcomeIndex.clamp(
      0,
      SessionRunOutcome.values.length - 1,
    );
    final rawFiles = json['filesChanged'];
    final files = rawFiles is List
        ? rawFiles.whereType<String>().toList()
        : <String>[];
    final rawMessages = json['messages'];
    final messages = rawMessages is List
        ? rawMessages
              .whereType<Map>()
              .map(
                (m) =>
                    SessionHistoryMessage.fromJson(m.cast<String, dynamic>()),
              )
              .toList()
        : <SessionHistoryMessage>[];

    return SessionHistoryItem(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String?,
      projectId: json['projectId'] as String?,
      task: json['task'] as String? ?? 'Untitled task',
      startedAt: json['startedAt'] as String? ?? '',
      endedAt: json['endedAt'] as String? ?? '',
      outcome: SessionRunOutcome.values[safeOutcomeIndex],
      resultSummary: json['resultSummary'] as String? ?? '',
      filesChanged: files,
      durationMs: json['durationMs'] as int?,
      messages: messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sessionId': sessionId,
    'projectId': projectId,
    'task': task,
    'startedAt': startedAt,
    'endedAt': endedAt,
    'outcome': outcome.index,
    'resultSummary': resultSummary,
    'filesChanged': filesChanged,
    'durationMs': durationMs,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}
