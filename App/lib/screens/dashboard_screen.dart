/// Dashboard — active session view with task input, preflight/decision cards, log preview.
/// CLI-themed redesign — matches the solid navigation bar style.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../providers/session_provider.dart';
import '../providers/daemon_actions_provider.dart';
import '../widgets/preflight_card.dart';
import '../widgets/decision_card.dart';
import '../widgets/task_input.dart';
import '../widgets/chat_message_list.dart';
import '../utils/formatters.dart';
import '../theme/cli_theme.dart';

// ── Fade-slide-in wrapper ─────────────────────────────────────────────────────
class _FadeSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _FadeSlide({required this.child, this.delay = Duration.zero});

  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

// ── Main screen ───────────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final actions = ref.read(daemonActionsProvider);

    return CliTheme(
      level: session.dependenceLevel,
      child: Builder(
        builder: (context) {
          final cli = CliTheme.of(context);
          return Container(
            color: cli.bg,
            child: Column(
              children: [
                // ── Scrollable Area ──────────────────────────────────────
                Expanded(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 48), // Space for floating status bar
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Preflight queue ──────────────────────────────
                            if (session.preflightQueue.isNotEmpty)
                              _FadeSlide(
                                delay: const Duration(milliseconds: 60),
                                child: _CliSection(
                                  label: 'PREFLIGHT',
                                  borderColor: cli.amber,
                                  child: PreflightCard(
                                    item: session.preflightQueue.first,
                                    onApprove: (id) {
                                      actions.approve(id);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .resolvePreflight(id);
                                    },
                                    onReject: (id) {
                                      actions.reject(id);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .resolvePreflight(id);
                                    },
                                    onModify: (id, text) {
                                      actions.answer(id, text);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .resolvePreflight(id);
                                    },
                                  ),
                                ),
                              ),

                            // ── Decision queue ───────────────────────────────
                            if (session.decisionQueue.isNotEmpty)
                              _FadeSlide(
                                delay: const Duration(milliseconds: 60),
                                child: _CliSection(
                                  label: 'DECISION REQUIRED',
                                  borderColor: cli.cyan,
                                  child: DecisionCard(
                                    item: session.decisionQueue.first,
                                    onAnswer: (id, answer) {
                                      actions.answer(id, answer);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .resolveDecision(id);
                                    },
                                    onReject: (id) {
                                      actions.reject(id);
                                      ref
                                          .read(sessionProvider.notifier)
                                          .resolveDecision(id);
                                    },
                                  ),
                                ),
                              ),

                            // ── Last completed ───────────────────────────────
                            if (session.lastComplete != null &&
                                session.status == SessionStatus.idle)
                              _FadeSlide(
                                delay: const Duration(milliseconds: 80),
                                child: _TerminalResultCard(
                                  isSuccess: true,
                                  title: 'TASK COMPLETED',
                                  body: session.lastComplete!.summary,
                                  meta:
                                      '${session.lastComplete!.filesChanged.length} files changed'
                                      '  ·  ${formatDurationMs(session.lastComplete!.durationMs)}',
                                ),
                              ),

                            // ── Last failed ──────────────────────────────────
                            if (session.lastFailed != null &&
                                session.status == SessionStatus.failed)
                              _FadeSlide(
                                delay: const Duration(milliseconds: 80),
                                child: _TerminalResultCard(
                                  isSuccess: false,
                                  title: 'TASK FAILED',
                                  body: session.lastFailed!.error,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // ── Chat log fills remaining space ───────────────────
                      if (session.logs.any((l) => l.level != AgentLogLevel.error) &&
                          session.preflightQueue.isEmpty &&
                          session.decisionQueue.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: true,
                          child: ChatMessageList(
                            logs: session.logs
                                .where((l) => l.level != AgentLogLevel.error)
                                .toList(),
                          ),
                        ),

                      // Bottom padding so chat doesn't touch the start of the bar
                      const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                    ],
                  ),
                    ),
                  ),
                ),

                // ── Solid bottom input area ──────────────────────────────────
                // Matches the style of the bottom navigation bar
                _BottomBar(session: session, actions: actions, ref: ref),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Wraps a child in a CLI-styled bordered section ────────────────────────────
class _CliSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Color? borderColor;

  const _CliSection(
      {required this.label, required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: cli.box(borderColor: borderColor ?? cli.border),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (borderColor ?? cli.accentDim).withValues(alpha: 0.12),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                border: Border(
                    bottom: BorderSide(
                        color: borderColor ?? cli.border, width: 1)),
              ),
              child: Text(
                '▸ $label',
                style: cli.mono.copyWith(
                    color: borderColor ?? cli.accent,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Terminal result card (success / failure) ──────────────────────────────────
class _TerminalResultCard extends StatelessWidget {
  final bool isSuccess;
  final String title;
  final String body;
  final String? meta;

  const _TerminalResultCard({
    required this.isSuccess,
    required this.title,
    required this.body,
    this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    final accent = isSuccess ? cli.accent : cli.red;

    final bgColor = isSuccess ? cli.accentMuted : cli.redMuted;
    final icon = isSuccess ? '✓' : '✗';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: cli.box(borderColor: accent, bgColor: bgColor),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('$icon ',
                    style: cli.mono.copyWith(color: accent, fontSize: 14)),
                Text(
                  title,
                  style: cli.mono.copyWith(
                      color: accent,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: cli.mono.copyWith(color: cli.text, fontSize: 13, height: 1.5),
            ),
            if (meta != null) ...[
              const SizedBox(height: 6),
              Text(
                meta!,
                style: cli.mono.copyWith(color: cli.textDim, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Bottom input bar ──────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final SessionState session;
  final dynamic actions;
  final WidgetRef ref;

  const _BottomBar(
      {required this.session, required this.actions, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    // Show input when idle (no active task) OR after a failure (allow retry).
    // When queues have items, those cards take over the bottom area.
    final canInput = (session.status == SessionStatus.idle ||
            session.status == SessionStatus.failed) &&
        session.preflightQueue.isEmpty &&
        session.decisionQueue.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cli.bg, // Solid background
        border: Border(top: BorderSide(color: cli.border, width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canInput) ...[
            // Terminal-style prompt row
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 2),
              child: Row(
                children: [
                  Text('codetwin',
                      style: cli.mono.copyWith(color: cli.accentDim, fontSize: 10)),
                  Text('@agent',
                      style: cli.mono.copyWith(color: cli.textDim, fontSize: 10)),
                  Text(' % ',
                      style: cli.mono.copyWith(color: cli.accent, fontSize: 10)),
                  if (session.status == SessionStatus.failed)
                    Text(' (last task failed — try again)',
                        style: cli.mono.copyWith(color: cli.amber, fontSize: 10)),
                ],
              ),
            ),
            TaskInput(
              enabled: true,
              onSubmit: (task) => actions.submitTask(task),
            ),
          ],
        ],
      ),
    );
  }
}
