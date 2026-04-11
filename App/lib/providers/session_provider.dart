// Riverpod provider for the active session state.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../models/log_entry.dart';
import '../models/session_history.dart';
import 'session_history_provider.dart';

const Object _unset = Object();

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
  final int? runStartLogIndex;
  final String? runPrompt;
  final String? runStartedAt;

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
    this.runStartLogIndex,
    this.runPrompt,
    this.runStartedAt,
  });

  static const empty = SessionState();

  SessionState copyWith({
    Object? sessionId = _unset,
    Object? projectId = _unset,
    SessionStatus? status,
    Object? currentTask = _unset,
    int? dependenceLevel,
    List<LogEntry>? logs,
    List<PreflightItem>? preflightQueue,
    List<DecisionItem>? decisionQueue,
    Object? lastComplete = _unset,
    Object? lastFailed = _unset,
    Object? runStartLogIndex = _unset,
    Object? runPrompt = _unset,
    Object? runStartedAt = _unset,
  }) {
    return SessionState(
      sessionId: identical(sessionId, _unset)
          ? this.sessionId
          : sessionId as String?,
      projectId: identical(projectId, _unset)
          ? this.projectId
          : projectId as String?,
      status: status ?? this.status,
      currentTask: identical(currentTask, _unset)
          ? this.currentTask
          : currentTask as String?,
      dependenceLevel: dependenceLevel ?? this.dependenceLevel,
      logs: logs ?? this.logs,
      preflightQueue: preflightQueue ?? this.preflightQueue,
      decisionQueue: decisionQueue ?? this.decisionQueue,
      lastComplete: identical(lastComplete, _unset)
          ? this.lastComplete
          : lastComplete as TaskCompletePayload?,
      lastFailed: identical(lastFailed, _unset)
          ? this.lastFailed
          : lastFailed as TaskFailedPayload?,
      runStartLogIndex: identical(runStartLogIndex, _unset)
          ? this.runStartLogIndex
          : runStartLogIndex as int?,
      runPrompt: identical(runPrompt, _unset)
          ? this.runPrompt
          : runPrompt as String?,
      runStartedAt: identical(runStartedAt, _unset)
          ? this.runStartedAt
          : runStartedAt as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

/// Maximum number of log entries retained in memory.
const _maxLogEntries = 1000;

bool _isChatInteraction(LogEntry log) {
  if (log.source == LogSource.raw) return false;
  if (log.source == LogSource.local) return true;
  final type = log.structuredType;
  if (type == null) return true;
  return type == 'text' || type == 'error';
}

bool _isUserLog(LogEntry entry) {
  return entry.message.startsWith('> Task:') ||
      entry.message.startsWith('> Answer:');
}

String _normalizedMessage(String message) {
  if (message.startsWith('> Task: ')) {
    return message.substring(8).trim();
  }
  if (message.startsWith('> Answer: ')) {
    return message.substring(10).trim();
  }
  return message.trim();
}

String? _extractTask(List<LogEntry> logs) {
  for (final log in logs) {
    if (log.message.startsWith('> Task: ')) {
      final task = log.message.substring(8).trim();
      if (task.isNotEmpty) return task;
    }
  }
  return null;
}

class SessionNotifier extends AsyncNotifier<SessionState> {
  @override
  Future<SessionState> build() async {
    return const SessionState();
  }

  SessionState get _s => state.valueOrNull ?? SessionState.empty;

  void appendLog(LogEntry entry) {
    final newLogs = [..._s.logs, entry];
    // Drop oldest entries when exceeding the cap
    final trimmed = newLogs.length > _maxLogEntries
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
    state = AsyncData(_s.copyWith(decisionQueue: [..._s.decisionQueue, item]));
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
    // Dependence level modifies permission rules in CLI sessions.
    // Reset stored session id so next run starts a fresh session with new rules.
    state = AsyncData(
      _s.copyWith(dependenceLevel: level.clamp(1, 5), sessionId: null),
    );
  }

  void setCurrentTask(String? task) {
    state = AsyncData(_s.copyWith(currentTask: task));
  }

  void setSessionId(String? sessionId) {
    state = AsyncData(_s.copyWith(sessionId: sessionId));
  }

  void setSession(String sessionId, String projectId) {
    state = AsyncData(_s.copyWith(sessionId: sessionId, projectId: projectId));
  }

  void beginTaskRun(String task) {
    state = AsyncData(
      _s.copyWith(
        runStartLogIndex: _s.logs.length,
        runPrompt: task.trim().isEmpty ? 'Untitled task' : task.trim(),
        runStartedAt: DateTime.now().toIso8601String(),
        lastComplete: null,
        lastFailed: null,
      ),
    );
  }

  void setLastComplete(TaskCompletePayload payload) {
    final snapshot = _s;
    state = AsyncData(
      snapshot.copyWith(
        lastComplete: payload,
        status: SessionStatus.idle,
        runStartLogIndex: null,
        runPrompt: null,
        runStartedAt: null,
      ),
    );
    _archiveRun(
      snapshot: snapshot,
      outcome: SessionRunOutcome.completed,
      resultSummary: payload.summary,
      filesChanged: payload.filesChanged,
      durationMs: payload.durationMs,
    );
  }

  void setLastFailed(TaskFailedPayload payload) {
    final snapshot = _s;
    state = AsyncData(
      snapshot.copyWith(
        lastFailed: payload,
        status: SessionStatus.failed,
        runStartLogIndex: null,
        runPrompt: null,
        runStartedAt: null,
      ),
    );
    _archiveRun(
      snapshot: snapshot,
      outcome: SessionRunOutcome.failed,
      resultSummary: payload.error,
      filesChanged: payload.filesChanged,
      durationMs: null,
    );
  }

  void syncFromStatus(SessionStatusPayload payload) {
    state = AsyncData(
      _s.copyWith(
        status: payload.status,
        currentTask: payload.currentTask,
        dependenceLevel: payload.dependenceLevel,
      ),
    );
  }

  void clearLogs() {
    state = AsyncData(_s.copyWith(logs: []));
  }

  bool startNewChat() {
    final snapshot = _s;
    var archived = false;

    // If a run is in progress (or pending completion), archive the chat before clearing.
    // This makes "New Chat" behave like ChatGPT's thread rollover.
    if (snapshot.runStartLogIndex != null ||
        snapshot.runPrompt != null ||
        snapshot.runStartedAt != null) {
      final outcome = snapshot.lastFailed != null
          ? SessionRunOutcome.failed
          : SessionRunOutcome.completed;
      final resultSummary =
          snapshot.lastFailed?.error ??
          snapshot.lastComplete?.summary ??
          'Chat archived before starting a new one.';
      final filesChanged =
          snapshot.lastFailed?.filesChanged ??
          snapshot.lastComplete?.filesChanged ??
          const <String>[];
      final durationMs = snapshot.lastComplete?.durationMs;

      _archiveRun(
        snapshot: snapshot,
        outcome: outcome,
        resultSummary: resultSummary,
        filesChanged: filesChanged,
        durationMs: durationMs,
      );
      archived = true;
    }

    state = AsyncData(
      snapshot.copyWith(
        sessionId: null,
        status: SessionStatus.idle,
        currentTask: null,
        logs: [],
        preflightQueue: [],
        decisionQueue: [],
        lastComplete: null,
        lastFailed: null,
        runStartLogIndex: null,
        runPrompt: null,
        runStartedAt: null,
      ),
    );

    return archived;
  }

  void _archiveRun({
    required SessionState snapshot,
    required SessionRunOutcome outcome,
    required String resultSummary,
    required List<String> filesChanged,
    required int? durationMs,
  }) {
    final clampedStart = (snapshot.runStartLogIndex ?? 0).clamp(
      0,
      snapshot.logs.length,
    );
    final scopedLogs = snapshot.logs.sublist(clampedStart);
    final chatLogs = scopedLogs.where(_isChatInteraction).toList();

    final task =
        snapshot.runPrompt ??
        _extractTask(chatLogs) ??
        snapshot.currentTask ??
        'Untitled task';

    final startedAt =
        snapshot.runStartedAt ??
        (chatLogs.isNotEmpty
            ? chatLogs.first.timestamp
            : DateTime.now().toIso8601String());

    final historyItem = SessionHistoryItem(
      id: 'run_${DateTime.now().microsecondsSinceEpoch}',
      sessionId: snapshot.sessionId,
      projectId: snapshot.projectId,
      task: task,
      startedAt: startedAt,
      endedAt: DateTime.now().toIso8601String(),
      outcome: outcome,
      resultSummary: resultSummary,
      filesChanged: filesChanged,
      durationMs: durationMs,
      messages: chatLogs
          .map(
            (entry) => SessionHistoryMessage(
              id: entry.id,
              timestamp: entry.timestamp,
              isUser: _isUserLog(entry),
              message: _normalizedMessage(entry.message),
              level: entry.level,
              structuredType: entry.structuredType,
            ),
          )
          .toList(),
    );

    unawaited(ref.read(sessionHistoryProvider.notifier).add(historyItem));
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
