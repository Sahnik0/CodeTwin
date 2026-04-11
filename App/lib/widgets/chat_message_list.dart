import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../utils/formatters.dart';
import '../theme/cli_theme.dart';

class ChatMessageList extends StatefulWidget {
  final List<LogEntry> logs;
  
  const ChatMessageList({super.key, required this.logs});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void didUpdateWidget(ChatMessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: widget.logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = widget.logs[index];
        final isUser = entry.message.startsWith('> Task:') || entry.message.startsWith('> Answer:');
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: _AnimatedChatBubble(
            key: ValueKey(entry.id),
            entry: entry,
            isUser: isUser,
          ),
        );
      },
    );
  }
}

class _AnimatedChatBubble extends StatefulWidget {
  final LogEntry entry;
  final bool isUser;

  const _AnimatedChatBubble({
    Key? key,
    required this.entry,
    required this.isUser,
  }) : super(key: key);

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
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

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
          alignment: widget.isUser ? Alignment.bottomRight : Alignment.bottomLeft,
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
    Color bgColor = isUser 
      ? cli.accentDim
      : cli.surface;
    
    Color textColor = isUser
      ? Colors.white
      : cli.text;

    if (entry.level == AgentLogLevel.error) {
      bgColor = cli.redMuted;
      textColor = cli.red;
    }

    IconData? leftIcon;
    if (!isUser) {
      if (entry.level == AgentLogLevel.tool) leftIcon = Icons.build_circle_outlined;
      else if (entry.level == AgentLogLevel.error) leftIcon = Icons.error_outline;
      else if (entry.level == AgentLogLevel.info) leftIcon = Icons.info_outline;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: isUser ? null : Border.all(
            color: cli.border,
            width: 1,
          ),
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
                  Icon(leftIcon, size: 14, color: textColor.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    entry.toolName ?? (entry.level == AgentLogLevel.error ? 'Error' : 'Agent'),
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
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
