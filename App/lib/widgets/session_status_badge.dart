/// Badge showing the current session status (idle, running, awaiting, etc.).

import 'package:flutter/material.dart';
import '../models/session_status.dart';

class SessionStatusBadge extends StatelessWidget {
  final SessionStatus status;
  final String? currentTask;

  const SessionStatusBadge({super.key, required this.status, this.currentTask});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label, IconData icon) = switch (status) {
      SessionStatus.idle => (
          Colors.white,
          Colors.black,
          'Idle',
          Icons.pause_circle_outline,
        ),
      SessionStatus.running => (
          Colors.blue.shade900,
          Colors.blue.shade200,
          currentTask?.isNotEmpty == true ? currentTask! : 'Running',
          Icons.play_circle_outline,
        ),
      SessionStatus.awaitingApproval => (
          Colors.amber.shade900,
          Colors.amber.shade200,
          'Awaiting',
          Icons.front_hand_outlined,
        ),
      SessionStatus.paused => (
          Colors.orange.shade900,
          Colors.orange.shade200,
          'Paused',
          Icons.pause_outlined,
        ),
      SessionStatus.failed => (
          Colors.red.shade900,
          Colors.red.shade200,
          'Failed',
          Icons.error_outline,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.8), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
