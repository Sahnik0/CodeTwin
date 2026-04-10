/// Riverpod provider for the active session state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../models/log_entry.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SessionState {
  final String? sessionId;
  final String? projectId;
  final SessionStatus status;
  final String? currentTask;
  final int dependenceLevel; // 1–5
  final List<LogEntry> logs; // capped at 1000
  final List<PreflightItem> preflightQueue;
  final List<DecisionItem> decisionQueue;
  final TaskCompletePayload? lastComplete;
  final TaskFailedPayload? lastFailed;

  const SessionState({
    this.sessionId,
    this.projectId,
    this.status = SessionStatus.idle,
    this.currentTask,
    this.dependenceLevel = 3,
    this.logs = const [],
    this.preflightQueue = const [],
    this.decisionQueue = const [],
    this.lastComplete,
    this.lastFailed,
  });

  static const empty = SessionState();

  SessionState copyWith({
    String? sessionId,
    String? projectId,
    SessionStatus? status,
    String? currentTask,
    int? dependenceLevel,
    List<LogEntry>? logs,
    List<PreflightItem>? preflightQueue,
    List<DecisionItem>? decisionQueue,
    TaskCompletePayload? lastComplete,
    TaskFailedPayload? lastFailed,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      currentTask: currentTask ?? this.currentTask,
      dependenceLevel: dependenceLevel ?? this.dependenceLevel,
      logs: logs ?? this.logs,
      preflightQueue: preflightQueue ?? this.preflightQueue,
      decisionQueue: decisionQueue ?? this.decisionQueue,
      lastComplete: lastComplete ?? this.lastComplete,
      lastFailed: lastFailed ?? this.lastFailed,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Maximum number of log entries retained in memory.
const _maxLogEntries = 1000;

class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    return const SessionState();
  }

  SessionState get _s => state.valueOrNull ?? SessionState.empty;

  void appendLog(LogEntry entry) {
    final newLogs = [..._s.logs, entry];
    // Drop oldest entries when exceeding the cap
    final trimmed =
        newLogs.length > _maxLogEntries
            ? newLogs.sublist(newLogs.length - _maxLogEntries)
            : newLogs;
    state = AsyncData(_s.copyWith(logs: trimmed));
  }

  void pushPreflight(PreflightItem item) {
    state = AsyncData(
      _s.copyWith(preflightQueue: [..._s.preflightQueue, item]),
    );
  }

  void resolvePreflight(String awaitingResponseId) {
    state = AsyncData(
      _s.copyWith(
        preflightQueue: _s.preflightQueue
            .where((p) => p.awaitingResponseId != awaitingResponseId)
            .toList(),
      ),
    );
  }

  void pushDecision(DecisionItem item) {
    state = AsyncData(
      _s.copyWith(decisionQueue: [..._s.decisionQueue, item]),
    );
  }

  void resolveDecision(String awaitingResponseId) {
    state = AsyncData(
      _s.copyWith(
        decisionQueue: _s.decisionQueue
            .where((d) => d.awaitingResponseId != awaitingResponseId)
            .toList(),
      ),
    );
  }

  void setStatus(SessionStatus status) {
    state = AsyncData(_s.copyWith(status: status));
  }

  void setLevel(int level) {
    state = AsyncData(_s.copyWith(dependenceLevel: level.clamp(1, 5)));
  }

  void setCurrentTask(String? task) {
    state = AsyncData(_s.copyWith(currentTask: task));
  }

  void setSession(String sessionId, String projectId) {
    state = AsyncData(
      _s.copyWith(sessionId: sessionId, projectId: projectId),
    );
  }

  void setLastComplete(TaskCompletePayload payload) {
    state = AsyncData(
      _s.copyWith(lastComplete: payload, status: SessionStatus.idle),
    );
  }

  void setLastFailed(TaskFailedPayload payload) {
    state = AsyncData(
      _s.copyWith(lastFailed: payload, status: SessionStatus.failed),
    );
  }

  void syncFromStatus(SessionStatusPayload payload) {
    state = AsyncData(_s.copyWith(
      status: payload.status,
      currentTask: payload.currentTask,
      dependenceLevel: payload.dependenceLevel,
    ));
  }

  void clearLogs() {
    state = AsyncData(_s.copyWith(logs: []));
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
