import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../theme/cli_theme.dart';
import '../widgets/decision_card.dart';

class ChatMessageList extends StatefulWidget {
  final List<LogEntry> logs;
  final DecisionItem? pendingDecision;
  final void Function(String awaitingResponseId, String answer)?
  onDecisionAnswer;
  final void Function(String awaitingResponseId)? onDecisionReject;
  final bool showTimelineLink;
  final VoidCallback? onViewTimeline;
  final double topPadding;
  final double bottomPadding;

  const ChatMessageList({
    super.key,
    required this.logs,
    this.pendingDecision,
    this.onDecisionAnswer,
    this.onDecisionReject,
    this.showTimelineLink = false,
    this.onViewTimeline,
    this.topPadding = 0.0,
    this.bottomPadding = 140.0,
  });

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();
  static const double _followThresholdPx = 120;

  bool _autoFollow = true;
  bool _showJumpToLatest = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _scheduleAutoFollow();
  }

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final hadDecision = oldWidget.pendingDecision != null;
    final hasDecision = widget.pendingDecision != null;
    final hadTimelineLink = oldWidget.showTimelineLink;
    final hasTimelineLink = widget.showTimelineLink;
    final hadNewLog = widget.logs.length > oldWidget.logs.length;
    if (hadNewLog ||
        (!hadDecision && hasDecision) ||
        (!hadTimelineLink && hasTimelineLink)) {
      if (_autoFollow || _isNearBottom()) {
        _scheduleAutoFollow();
      } else if (!_showJumpToLatest) {
        setState(() => _showJumpToLatest = true);
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (!_hasTimelineContent) return;

    final nearBottom = _isNearBottom();
    if (nearBottom) {
      if (!_autoFollow || _showJumpToLatest) {
        setState(() {
          _autoFollow = true;
          _showJumpToLatest = false;
        });
      }
      return;
    }

    if (_autoFollow || !_showJumpToLatest) {
      setState(() {
        _autoFollow = false;
        _showJumpToLatest = true;
      });
    }
  }

  bool get _hasTimelineContent {
    return widget.logs.isNotEmpty ||
        widget.pendingDecision != null ||
        widget.showTimelineLink;
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    final distance = position.maxScrollExtent - position.pixels;
    return distance <= _followThresholdPx;
  }

  void _scheduleAutoFollow() {
    if (!_autoFollow) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToBottom(animated: true);

      Future<void>.delayed(const Duration(milliseconds: 140), () {
        if (!mounted || !_autoFollow) return;
        _scrollToBottom(animated: false);
      });

      Future<void>.delayed(const Duration(milliseconds: 320), () {
        if (!mounted || !_autoFollow) return;
        _scrollToBottom(animated: false);
      });
    });
  }

  void _scrollToBottom({required bool animated}) {
    if (_scrollController.hasClients) {
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    }
  }

  void _jumpToLatest() {
    setState(() {
      _autoFollow = true;
      _showJumpToLatest = false;
    });
    _scheduleAutoFollow();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showDecision =
        widget.pendingDecision != null &&
        widget.onDecisionAnswer != null &&
        widget.onDecisionReject != null;
    final showTimelineLink =
        widget.showTimelineLink && widget.onViewTimeline != null;
    final totalCount =
        widget.logs.length +
        (showDecision ? 1 : 0) +
        (showTimelineLink ? 1 : 0);

    final jumpBottom = widget.bottomPadding > 96
        ? widget.bottomPadding - 92
        : 12.0;

    return Stack(
      children: [
        ListView.separated(
          controller: _scrollController,
          padding: EdgeInsets.only(
            top: widget.topPadding > 0 ? widget.topPadding : 8,
            bottom: widget.bottomPadding,
            left: 16,
            right: 16,
          ),
          itemCount: totalCount,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (showDecision && index == widget.logs.length) {
              return Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 16),
                          child: child,
                        ),
                      );
                    },
                    child: DecisionCard(
                      item: widget.pendingDecision!,
                      inChat: true,
                      onAnswer: widget.onDecisionAnswer!,
                      onReject: widget.onDecisionReject!,
                    ),
                  ),
                ),
              );
            }

            final timelineIndex = widget.logs.length + (showDecision ? 1 : 0);
            if (showTimelineLink && index == timelineIndex) {
              final cli = CliTheme.of(context);
              return Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: widget.onViewTimeline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: cli.box(
                        borderColor: cli.border,
                        bgColor: cli.surface,
                        radius: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: cli.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'View process timeline',
                            style: cli.mono.copyWith(
                              color: cli.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            final entry = widget.logs[index];
            final isUser =
                entry.message.startsWith('> Task:') ||
                entry.message.startsWith('> Answer:');

            if (!isUser && entry.structuredType == 'reasoning') {
              return _ThinkingEventCard(entry: entry);
            }

            if (!isUser &&
                (entry.structuredType == 'step_start' ||
                    entry.structuredType == 'step_finish')) {
              return _StepEventCard(entry: entry);
            }

            if (!isUser && entry.structuredType == 'tool_use') {
              return _StepEventCard(entry: entry, isToolEvent: true);
            }

            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: _AnimatedChatBubble(
                key: ValueKey(entry.id),
                entry: entry,
                isUser: isUser,
              ),
            );
          },
        ),
        Positioned(
          right: 20,
          bottom: jumpBottom,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 180),
            offset: _showJumpToLatest ? Offset.zero : const Offset(0, 1.1),
            curve: Curves.easeOutCubic,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showJumpToLatest ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showJumpToLatest,
                child: _JumpToLatestButton(onTap: _jumpToLatest),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _JumpToLatestButton extends StatelessWidget {
  final VoidCallback onTap;

  const _JumpToLatestButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: cli.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cli.accent.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_downward_rounded, size: 16, color: cli.accent),
              const SizedBox(width: 6),
              Text(
                'Latest',
                style: cli.mono.copyWith(
                  color: cli.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedChatBubble extends StatefulWidget {
  final LogEntry entry;
  final bool isUser;

  const _AnimatedChatBubble({
    super.key,
    required this.entry,
    required this.isUser,
  });

  @override
  State<_AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<_AnimatedChatBubble>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Bouncy scale for that iOS SMS feel
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Slide up slightly
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: widget.isUser
              ? Alignment.bottomRight
              : Alignment.bottomLeft,
          child: _ChatBubble(entry: widget.entry, isUser: widget.isUser),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final LogEntry entry;
  final bool isUser;

  const _ChatBubble({required this.entry, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);

    // Extract actual message if it's a user command
    String displayMessage = entry.message;
    if (isUser && displayMessage.startsWith('> Task: ')) {
      displayMessage = displayMessage.substring(8);
    } else if (isUser && displayMessage.startsWith('> Answer: ')) {
      displayMessage = displayMessage.substring(10);
    }

    // Determine bubble styling
    Color bgColor = isUser ? cli.accentDim : Colors.grey.shade900;

    Color textColor = isUser ? Colors.white : Colors.white;

    if (entry.level == AgentLogLevel.error) {
      bgColor = cli.redMuted;
      textColor = cli.red;
    }

    IconData? leftIcon;
    if (!isUser) {
      if (entry.structuredType == 'text') {
        leftIcon = null;
      } else if (entry.level == AgentLogLevel.tool) {
        leftIcon = Icons.build_circle_outlined;
      } else if (entry.level == AgentLogLevel.error) {
        leftIcon = Icons.error_outline;
      } else if (entry.level == AgentLogLevel.warn) {
        leftIcon = Icons.warning_amber_rounded;
      } else if (entry.level == AgentLogLevel.info) {
        leftIcon = Icons.info_outline;
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: isUser
              ? null
              : Border.all(color: Colors.grey.shade700, width: 1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && leftIcon != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    leftIcon,
                    size: 14,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.toolName ??
                        (entry.level == AgentLogLevel.error
                            ? 'Error'
                            : 'Agent'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Text(
              displayMessage,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepEventCard extends StatelessWidget {
  final LogEntry entry;
  final bool isToolEvent;

  const _StepEventCard({required this.entry, this.isToolEvent = false});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    final isStart = entry.structuredType == 'step_start';

    final icon = isToolEvent
        ? Icons.build_circle_outlined
        : isStart
        ? Icons.play_arrow_rounded
        : Icons.check_circle_outline;

    final title = isToolEvent
        ? 'Tool Event'
        : isStart
        ? 'Step Started'
        : 'Step Completed';

    return Container(
      margin: const EdgeInsets.only(right: 36),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cli.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cli.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cli.textDim),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: cli.mono.copyWith(
                    color: cli.textDim,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.message,
                  style: cli.mono.copyWith(
                    color: cli.text,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingEventCard extends StatelessWidget {
  final LogEntry entry;

  const _ThinkingEventCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    final text = entry.message.trim();
    final preview = text.length > 90 ? '${text.substring(0, 90)}...' : text;

    return Container(
      margin: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: cli.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cli.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          collapsedIconColor: cli.textDim,
          iconColor: cli.accent,
          title: Row(
            children: [
              Icon(Icons.psychology_alt_outlined, size: 16, color: cli.textDim),
              const SizedBox(width: 8),
              Text(
                'Thinking',
                style: cli.mono.copyWith(
                  color: cli.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          subtitle: Text(
            preview,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: cli.mono.copyWith(color: cli.textDim, fontSize: 11),
          ),
          children: [
            _TypewriterText(
              text: text,
              style: cli.mono.copyWith(
                color: cli.text,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypewriterText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _TypewriterText({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final durationMs = (text.length * 14).clamp(300, 1800);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final visible = (text.length * value).floor().clamp(0, text.length);
        final current = text.substring(0, visible);
        return Text(current, style: style);
      },
    );
  }
}
