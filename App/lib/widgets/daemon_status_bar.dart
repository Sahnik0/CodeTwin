/// Always-visible connection status banner at the top of every tab.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../providers/connection_provider.dart';

class DaemonStatusBar extends ConsumerWidget {
  const DaemonStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connAsync = ref.watch(connectionProvider);
    final conn = connAsync.valueOrNull ?? DaemonConnectionState.empty;

    final (Color color, IconData icon, String label) = switch (conn.pairingStatus) {
      PairingStatus.paired => (
          Colors.green,
          Icons.check_circle_outline,
          'Daemon online',
        ),
      PairingStatus.daemonOffline => (
          Colors.amber,
          Icons.cloud_off,
          'Daemon offline — waiting for reconnect',
        ),
      PairingStatus.connecting => (
          Colors.blue,
          Icons.sync,
          'Connecting…',
        ),
      PairingStatus.unpaired => (
          Colors.red,
          Icons.link_off,
          'Not paired',
        ),
    };

    return GestureDetector(
      onTap: () {
        // Navigate to settings if needed
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (conn.deviceId != null)
              Text(
                conn.deviceId!.substring(0, 6),
                style: TextStyle(
                  color: color.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
