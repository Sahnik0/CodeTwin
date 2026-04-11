// Session history screen with expandable decision logs.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/session_history.dart';
import '../providers/session_history_provider.dart';
import '../providers/session_provider.dart';
import '../theme/cli_theme.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sessionHistoryProvider);
    final level = ref.watch(sessionProvider).valueOrNull?.dependenceLevel ?? 3;

    return CliTheme(
      level: level,
      child: Builder(
        builder: (context) {
          final cli = CliTheme.of(context);

          return Scaffold(
            backgroundColor: const Color(0xFF0B0D10),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0D1013),
              title: const Text('Session History'),
              actions: [
                historyAsync.maybeWhen(
                  data: (items) {
                    if (items.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'Clear history',
                      color: cli.accent,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmClear(context, ref),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
            body: historyAsync.when(
              loading: () =>
                  Center(child: CircularProgressIndicator(color: cli.accent)),
              error: (error, _) => _HistoryError(
                error: error,
                onRetry: () =>
                    ref.read(sessionHistoryProvider.notifier).reload(),
              ),
              data: (items) => RefreshIndicator(
                color: cli.accent,
                onRefresh: () =>
                    ref.read(sessionHistoryProvider.notifier).reload(),
                child: items.isEmpty
                    ? const _EmptyHistoryState()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _SessionHistoryCard(
                            item: item,
                            onDelete: () =>
                                _confirmDeleteSession(context, ref, item),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: items.length,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final cli = CliTheme.of(context);
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111419),
          surfaceTintColor: Colors.transparent,
          title: const Text('Clear session history?'),
          content: const Text(
            'This removes all saved chat sessions from local history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Cancel', style: TextStyle(color: cli.textDim)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cli.accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await ref.read(sessionHistoryProvider.notifier).clear();
    }
  }

  Future<void> _confirmDeleteSession(
    BuildContext context,
    WidgetRef ref,
    SessionHistoryItem item,
  ) async {
    final cli = CliTheme.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF090A0D),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cli.red.withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: cli.red.withValues(alpha: 0.16),
                  blurRadius: 26,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  decoration: BoxDecoration(
                    color: cli.redMuted.withValues(alpha: 0.45),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: cli.red.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: cli.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'DELETE SESSION',
                        style: cli.mono.copyWith(
                          color: cli.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    'This action cannot be undone.\n\n${item.task}',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      height: 1.45,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: cli.textDim,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: cli.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      await ref.read(sessionHistoryProvider.notifier).removeById(item.id);
    }
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cli.accent.withValues(alpha: 0.1),
                  border: Border.all(
                    color: cli.accent.withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cli.accent.withValues(alpha: 0.06),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(Icons.history, size: 48, color: cli.accent),
              ),
              const SizedBox(height: 24),
              Text(
                'No Sessions Yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'Run a task from Dashboard. The full chat transcript will appear here as a saved session.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryError extends StatelessWidget {
  final Object error;
  final Future<void> Function() onRetry;

  const _HistoryError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return RefreshIndicator(
      color: cli.accent,
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 180),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Failed to load session history. Pull to retry.\n$error',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.74),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionHistoryCard extends StatefulWidget {
  final SessionHistoryItem item;
  final VoidCallback onDelete;

  const _SessionHistoryCard({required this.item, required this.onDelete});

  @override
  State<_SessionHistoryCard> createState() => _SessionHistoryCardState();
}

class _SessionHistoryCardState extends State<_SessionHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    final item = widget.item;
    final isSuccess = item.outcome == SessionRunOutcome.completed;
    final statusColor = isSuccess ? cli.accent : cli.red;
    const bgColor = Colors.black;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: _expanded ? 0.45 : 0.22),
          width: 1.2,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          onExpansionChanged: (value) => setState(() => _expanded = value),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: Colors.white.withValues(alpha: 0.8),
          collapsedIconColor: Colors.white.withValues(alpha: 0.5),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Delete session',
                visualDensity: VisualDensity.compact,
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: cli.red.withValues(alpha: 0.9),
                ),
              ),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
          title: Text(
            item.task,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _StatusPill(
                      text: isSuccess ? 'Completed' : 'Failed',
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(item.endedAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.resultSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          children: [
            if (item.messages.isEmpty)
              Text(
                'No chat transcript available for this session.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 12,
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: item.messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final msg = item.messages[index];
                    return Align(
                      alignment: msg.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.76,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? cli.accentMuted.withValues(alpha: 0.72)
                              : const Color(0xFF1D1F23),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: (msg.isUser ? cli.accent : Colors.white)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

String _formatDate(String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return 'Unknown date';
  return DateFormat('MMM d, yyyy • h:mm a').format(parsed.toLocal());
}
