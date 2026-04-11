/// Session history screen with expandable decision logs.

import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // History will be populated from daemon GET /sessions when connected.
    // For now, show an empty state.
    return Scaffold(
      backgroundColor: Colors.black,
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF20B2AA).withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFF20B2AA).withValues(alpha: 0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF20B2AA).withValues(alpha: 0.05),
                          blurRadius: 20,
                        ),
                      ]
                    ),
                    child: const Icon(Icons.history,
                        size: 48,
                        color: Color(0xFF20B2AA)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Workspaces Found',
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
                      'Completed iterations and historical sessions will be securely vaulted here.',
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
        ),
      ),
    );
  }
}
