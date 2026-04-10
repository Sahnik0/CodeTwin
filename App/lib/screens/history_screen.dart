/// Session history screen with expandable decision logs.

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // History will be populated from daemon GET /sessions when connected.
    // For now, show an empty state.
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: fetch sessions from daemon via HTTP GET /sessions
        },
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.history,
                      size: 56, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Submit a task from here or your terminal and '
                      'completed sessions will show up here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
