// Dashboard active session view with task input, cards, and log preview.
// CLI-themed redesign matching the navigation bar style.

import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../providers/session_provider.dart';
import '../providers/daemon_actions_provider.dart';
import '../widgets/preflight_card.dart';
import '../widgets/task_input.dart';
import '../widgets/chat_message_list.dart';
import '../utils/formatters.dart';
import '../widgets/daemon_status_bar.dart';
import '../widgets/session_status_badge.dart';
import '../theme/cli_theme.dart';

bool _isChatInteraction(LogEntry log) {
  if (log.source == LogSource.raw) return false;
  if (log.source == LogSource.local) return true;
  final type = log.structuredType;
  if (type == null) return true;
  return type == 'text' || type == 'error';
}

bool _isTimelineEvent(LogEntry log) {
  if (log.source != LogSource.structured) return false;
  final type = log.structuredType;
  return type != null && type != 'text';
}

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
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
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
    final chatLogs = session.logs.where(_isChatInteraction).toList();
    final timelineLogs = session.logs.where(_isTimelineEvent).toList();
    final shouldShowTimelineLink =
        session.status == SessionStatus.idle &&
        timelineLogs.isNotEmpty &&
        session.preflightQueue.isEmpty &&
        session.decisionQueue.isEmpty;
    final showStarterHint =
        session.status == SessionStatus.idle &&
        session.currentTask == null &&
        chatLogs.isEmpty &&
        session.preflightQueue.isEmpty &&
        session.decisionQueue.isEmpty &&
        session.lastComplete == null &&
        session.lastFailed == null;
    final hasTopCards =
        session.preflightQueue.isNotEmpty ||
        (session.lastComplete != null &&
            session.status == SessionStatus.idle) ||
        (session.lastFailed != null && session.status == SessionStatus.failed);

    return CliTheme(
      level: session.dependenceLevel,
      child: Builder(
        builder: (context) {
          final cli = CliTheme.of(context);
          final topInset = MediaQuery.paddingOf(context).top + 48;
          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return Container(
            color: cli.bg,
            child: Stack(
              children: [
                // ── Scrollable Area ──────────────────────────────────────
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.12, 0.78, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: CustomScrollView(
                      controller: ScrollController(),
                      slivers: [
                        if (hasTopCards)
                          SliverPadding(
                            padding: EdgeInsets.only(top: topInset),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                          ),
                        if ((chatLogs.isNotEmpty ||
                                session.decisionQueue.isNotEmpty) &&
                            session.preflightQueue.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: true,
                            child: ChatMessageList(
                              logs: chatLogs,
                              topPadding: hasTopCards ? 8.0 : topInset,
                              bottomPadding: 140 + bottomInset,
                              pendingDecision: session.decisionQueue.isEmpty
                                  ? null
                                  : session.decisionQueue.first,
                              showTimelineLink: shouldShowTimelineLink,
                              onViewTimeline: shouldShowTimelineLink
                                  ? () => context.go('/logs')
                                  : null,
                              onDecisionAnswer: (id, answer) {
                                actions.answer(id, answer);
                                ref
                                    .read(sessionProvider.notifier)
                                    .resolveDecision(id);
                              },
                              onDecisionReject: (id) {
                                actions.reject(id);
                                ref
                                    .read(sessionProvider.notifier)
                                    .resolveDecision(id);
                              },
                            ),
                          ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 120),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      opacity: showStarterHint ? 1 : 0,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          topInset + 20,
                          24,
                          160 + bottomInset,
                        ),
                        child: Center(
                          child: _NewChatStarterHint(
                            isVisible: showStarterHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomBar(
                    session: session,
                    actions: actions,
                    ref: ref,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.paddingOf(context).top + 4,
                      left: 10,
                      right: 10,
                    ),
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 32,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: _FloatingStatusBar(session: session),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.scale(
                                    scale: 0.75,
                                    child: const DaemonStatusBar(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NewChatStarterHint extends StatefulWidget {
  final bool isVisible;

  const _NewChatStarterHint({required this.isVisible});

  @override
  State<_NewChatStarterHint> createState() => _NewChatStarterHintState();
}

class _NewChatStarterHintState extends State<_NewChatStarterHint> {
  static const List<String> _lines = [
    'Drop the prompt, let CodeTwin cook.',
    'Say less, ship more, send the task.',
    'One message and we lock in on your code mission.',
    'Build mode: on. Type it and watch it move.',
    'Your repo, your vibe, your next win starts here.',
  ];

  final Random _random = Random();
  late String _line;

  @override
  void initState() {
    super.initState();
    _line = _pickLine();
  }

  @override
  void didUpdateWidget(covariant _NewChatStarterHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isVisible && widget.isVisible) {
      setState(() {
        _line = _pickLine(previous: _line);
      });
    }
  }

  String _pickLine({String? previous}) {
    if (_lines.length <= 1) return _lines.first;
    var next = _lines[_random.nextInt(_lines.length)];
    while (next == previous) {
      next = _lines[_random.nextInt(_lines.length)];
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 28,
          color: cli.accent.withValues(alpha: 0.72),
        ),
        const SizedBox(height: 14),
        Text(
          'Hey, what\'s up',
          style: cli.mono.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _line,
          style: cli.mono.copyWith(
            color: Colors.white.withValues(alpha: 0.44),
            fontSize: 12,
            height: 1.45,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Floating Status Bar ──────────────────────────────────────────────────────
class _FloatingStatusBar extends ConsumerWidget {
  final SessionState session;
  const _FloatingStatusBar({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Status Badge
        SessionStatusBadge(
          status: session.status,
          currentTask: session.currentTask,
        ),
        const Spacer(),
      ],
    );
  }
}

// ── Wraps a child in a CLI-styled bordered section ────────────────────────────
class _CliSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Color? borderColor;

  const _CliSection({
    required this.label,
    required this.child,
    this.borderColor,
  });

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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: borderColor ?? cli.border,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                '▸ $label',
                style: cli.mono.copyWith(
                  color: borderColor ?? cli.accent,
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
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
                Text(
                  '$icon ',
                  style: cli.mono.copyWith(color: accent, fontSize: 14),
                ),
                Text(
                  title,
                  style: cli.mono.copyWith(
                    color: accent,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: cli.mono.copyWith(
                color: cli.text,
                fontSize: 13,
                height: 1.5,
              ),
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

  const _BottomBar({
    required this.session,
    required this.actions,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    // Show input when idle (no active task) OR after a failure (allow retry).
    // When queues have items, those cards take over the bottom area.
    final canInput =
        (session.status == SessionStatus.idle ||
            session.status == SessionStatus.failed) &&
        session.preflightQueue.isEmpty &&
        session.decisionQueue.isEmpty;

    // Only show "New Chat" after at least one interaction exists.
    final hasStartedChat =
        session.logs.isNotEmpty ||
        session.runStartLogIndex != null ||
        (session.runPrompt?.trim().isNotEmpty ?? false) ||
        (session.currentTask?.trim().isNotEmpty ?? false) ||
        session.lastComplete != null ||
        session.lastFailed != null;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black, Colors.black, Colors.transparent],
          stops: [0.0, 0.86, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
          child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canInput) ...[
                  if (hasStartedChat) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final archived = ref
                                .read(sessionProvider.notifier)
                                .startNewChat();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  archived
                                      ? 'Previous chat saved to History. Started a new chat.'
                                      : 'Started a new chat.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_comment_outlined,
                            size: 16,
                          ),
                          label: const Text('New Chat'),
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: cli.accent,
                            backgroundColor: cli.surface.withValues(
                              alpha: 0.78,
                            ),
                            side: BorderSide(
                              color: cli.accent.withValues(alpha: 0.55),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TaskInput(
                    enabled: true,
                    onSubmit: (task) => actions.submitTask(task),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
