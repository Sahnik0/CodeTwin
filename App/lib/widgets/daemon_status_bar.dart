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

    if (conn.pairingStatus == PairingStatus.paired) {
      return const SizedBox.shrink(); // Hide completely when connected!
    }

    final (Color color, IconData icon, String label) = switch (conn.pairingStatus) {
      PairingStatus.paired => (
          Colors.green,
          Icons.check_circle_outline,
          'Daemon online',
        ),
      PairingStatus.daemonOffline => (
          Colors.amber,
          Icons.cloud_off,
          'Daemon offline — reconnecting',
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

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          // Navigate to settings if needed
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
