/// Session, pairing, and log-level enums + all typed payload models.

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

enum SessionStatus { idle, running, awaitingApproval, paused, failed }

enum PairingStatus { unpaired, connecting, paired, daemonOffline }

enum AgentLogLevel { info, warn, error, tool }

// ---------------------------------------------------------------------------
// Payloads received from daemon
// ---------------------------------------------------------------------------

class AwaitingApprovalPayload {
  final String question;
  final List<String>? options;
  final String awaitingResponseId;
  final int? timeoutMs;

  const AwaitingApprovalPayload({
    required this.question,
    this.options,
    required this.awaitingResponseId,
    this.timeoutMs,
  });
}

class AgentLogPayload {
  final AgentLogLevel level;
  final String message;
  final String? toolName;

  const AgentLogPayload({
    required this.level,
    required this.message,
    this.toolName,
  });
}

class TaskCompletePayload {
  final String summary;
  final int decisionsRecorded;
  final List<String> filesChanged;
  final int durationMs;

  const TaskCompletePayload({
    required this.summary,
    required this.decisionsRecorded,
    required this.filesChanged,
    required this.durationMs,
  });
}

class TaskFailedPayload {
  final String error;
  final String partialCompletionSummary;
  final List<String> filesChanged;

  const TaskFailedPayload({
    required this.error,
    required this.partialCompletionSummary,
    required this.filesChanged,
  });
}

class SessionStatusPayload {
  final SessionStatus status;
  final String? currentTask;
  final int dependenceLevel; // 1–5
  final bool remoteConnected;

  const SessionStatusPayload({
    required this.status,
    this.currentTask,
    required this.dependenceLevel,
    required this.remoteConnected,
  });
}

// ---------------------------------------------------------------------------
// Payloads sent from app
// ---------------------------------------------------------------------------

class TaskSubmitPayload {
  final String task;
  final int? dependenceLevel;

  const TaskSubmitPayload({required this.task, this.dependenceLevel});

  Map<String, dynamic> toJson() => {
        'task': task,
        if (dependenceLevel != null) 'dependenceLevel': dependenceLevel,
      };
}

class UserAnswerPayload {
  final String awaitingResponseId;
  final String answer;

  const UserAnswerPayload({
    required this.awaitingResponseId,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'awaitingResponseId': awaitingResponseId,
        'answer': answer,
      };
}

class LevelChangePayload {
  final int newLevel;

  const LevelChangePayload({required this.newLevel});

  Map<String, dynamic> toJson() => {'newLevel': newLevel};
}
