/// Dashboard — active session view with task input, preflight/decision cards, log preview.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/session_status.dart';
import '../providers/session_provider.dart';
import '../providers/connection_provider.dart';
import '../providers/daemon_actions_provider.dart';
import '../widgets/session_status_badge.dart';
import '../widgets/preflight_card.dart';
import '../widgets/decision_card.dart';
import '../widgets/task_input.dart';
import '../widgets/level_picker.dart';
import '../widgets/agent_log_list.dart';
import '../utils/formatters.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final conn = ref.watch(connectionProvider).valueOrNull ??
        DaemonConnectionState.empty;
    final actions = ref.read(daemonActionsProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top: session status ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SessionStatusBadge(status: session.status),
                    const Spacer(),
                    if (session.status == SessionStatus.running)
                      TextButton.icon(
                        onPressed: () => actions.cancelTask(),
                        icon: const Icon(Icons.stop, size: 18),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
                if (session.currentTask != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    session.currentTask!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                LevelPicker(
                  currentLevel: session.dependenceLevel,
                  onChanged: (level) {
                    ref.read(sessionProvider.notifier).setLevel(level);
                    actions.changeLevel(level);
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Middle: active cards ─────────────────────────────────────

          // Preflight queue
          if (session.preflightQueue.isNotEmpty)
            PreflightCard(
              item: session.preflightQueue.first,
              onApprove: (id) {
                actions.approve(id);
                ref.read(sessionProvider.notifier).resolvePreflight(id);
              },
              onReject: (id) {
                actions.reject(id);
                ref.read(sessionProvider.notifier).resolvePreflight(id);
              },
              onModify: (id, text) {
                actions.answer(id, text);
                ref.read(sessionProvider.notifier).resolvePreflight(id);
              },
            ),

          // Decision queue
          if (session.decisionQueue.isNotEmpty)
            DecisionCard(
              item: session.decisionQueue.first,
              onAnswer: (id, answer) {
                actions.answer(id, answer);
                ref.read(sessionProvider.notifier).resolveDecision(id);
              },
              onReject: (id) {
                actions.reject(id);
                ref.read(sessionProvider.notifier).resolveDecision(id);
              },
            ),

          // Idle: show task input
          if (session.status == SessionStatus.idle &&
              session.preflightQueue.isEmpty &&
              session.decisionQueue.isEmpty)
            TaskInput(
              enabled: conn.daemonConnected,
              onSubmit: (task) => actions.submitTask(task),
            ),

          // Last completed task summary
          if (session.lastComplete != null &&
              session.status == SessionStatus.idle) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.green.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text('Last task completed',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(session.lastComplete!.summary),
                    const SizedBox(height: 4),
                    Text(
                      '${session.lastComplete!.filesChanged.length} files changed • '
                      '${formatDurationMs(session.lastComplete!.durationMs)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Last failed task
          if (session.lastFailed != null &&
              session.status == SessionStatus.failed) ...[
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text('Task failed',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(session.lastFailed!.error),
                  ],
                ),
              ),
            ),
          ],

          // Running (no pending): show last 5 logs
          if (session.status == SessionStatus.running &&
              session.preflightQueue.isEmpty &&
              session.decisionQueue.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text('Live Logs', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/logs'),
                    child: const Text('View all →'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: AgentLogList(
                logs: session.logs.length > 5
                    ? session.logs.sublist(session.logs.length - 5)
                    : session.logs,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
