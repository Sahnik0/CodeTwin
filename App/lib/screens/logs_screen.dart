/// Streaming agent log viewer with filter and auto-scroll.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../providers/session_provider.dart';
import '../widgets/agent_log_list.dart';

class LogsScreen extends ConsumerStatefulWidget {
  const LogsScreen({super.key});

  @override
  ConsumerState<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends ConsumerState<LogsScreen> {
  AgentLogLevel? _filter;

  @override
  Widget build(BuildContext context) {
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear logs',
            onPressed: () => ref.read(sessionProvider.notifier).clearLogs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<AgentLogLevel?>(
              segments: const [
                ButtonSegment(value: null, label: Text('All')),
                ButtonSegment(value: AgentLogLevel.info, label: Text('Info')),
                ButtonSegment(value: AgentLogLevel.warn, label: Text('Warn')),
                ButtonSegment(value: AgentLogLevel.error, label: Text('Error')),
                ButtonSegment(value: AgentLogLevel.tool, label: Text('Tool')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) =>
                  setState(() => _filter = s.first),
              showSelectedIcon: false,
            ),
          ),

          // Log list
          Expanded(
            child: session.logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 12),
                        Text(
                          'No logs yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Logs will appear here when the agent starts working.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  )
                : AgentLogList(logs: session.logs, filter: _filter),
          ),
        ],
      ),
    );
  }
}
