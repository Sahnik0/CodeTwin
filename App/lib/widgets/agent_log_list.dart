/// Scrollable, color-coded streaming log viewer.

import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import '../models/session_status.dart';
import '../utils/formatters.dart';

class AgentLogList extends StatefulWidget {
  final List<LogEntry> logs;
  final AgentLogLevel? filter;

  const AgentLogList({super.key, required this.logs, this.filter});

  @override
  State<AgentLogList> createState() => _AgentLogListState();
}

class _AgentLogListState extends State<AgentLogList> {
  final ScrollController _scrollController = ScrollController();
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(AgentLogList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isNearBottom && widget.logs.length > oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    setState(() {
      _isNearBottom = pos.pixels >= pos.maxScrollExtent - 80;
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.filter == null
        ? widget.logs
        : widget.logs.where((l) => l.level == widget.filter).toList();

    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          itemCount: filtered.length,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return _LogRow(entry: entry);
          },
        ),
        if (!_isNearBottom)
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: _scrollToBottom,
              child: const Icon(Icons.arrow_downward, size: 18),
            ),
          ),
      ],
    );
  }
}

class _LogRow extends StatelessWidget {
  final LogEntry entry;

  const _LogRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final (Color color, String badge) = switch (entry.level) {
      AgentLogLevel.info => (Colors.grey.shade400, 'INF'),
      AgentLogLevel.warn => (Colors.amber, 'WRN'),
      AgentLogLevel.error => (Colors.red, 'ERR'),
      AgentLogLevel.tool => (Colors.purple.shade300, 'TUL'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timestamp
          Text(
            formatTimestamp(entry.timestamp),
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 6),
          // Level badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (entry.source == LogSource.raw) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: const Text(
                'RAW',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
          const SizedBox(width: 6),
          // Tool name
          if (entry.toolName != null) ...[
            Text(
              entry.toolName!,
              style: TextStyle(
                color: Colors.purple.shade300,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
          ],
          // Message
          Expanded(
            child: Text(
              entry.message,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
