// Settings screen — pairing info, level override, notifications, app version.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/connection_provider.dart';
import '../providers/session_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/daemon_actions_provider.dart';
import '../widgets/level_picker.dart';
import '../widgets/restart_widget.dart';
import '../services/token_store.dart';
import '../services/socket_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final conn =
        ref.watch(connectionProvider).valueOrNull ??
        DaemonConnectionState.empty;
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final notif =
        ref.watch(notificationsProvider).valueOrNull ??
        const NotificationsState();
    final actions = ref.read(daemonActionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Pairing ─────────────────────────────────────────────────
          _sectionHeader(theme, 'Pairing & Device'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16161A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Pairing ID row
                ListTile(
                  leading: const Icon(Icons.link, color: Colors.white70),
                  title: const Text(
                    'Pairing ID',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    conn.pairingId ?? 'Not paired',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

                // Mobile Device ID
                ListTile(
                  leading: const Icon(Icons.smartphone, color: Colors.white70),
                  title: const Text(
                    'Mobile Device ID',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    conn.mobileDeviceId ?? 'Not paired',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

                // Server URL
                ListTile(
                  leading: const Icon(Icons.cloud, color: Colors.white70),
                  title: const Text(
                    'Server URL',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    conn.apiBaseUrl.isEmpty
                        ? 'Not configured'
                        : conn.apiBaseUrl,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

                // Token Expiry
                if (conn.tokenExpiresAt != null)
                  ListTile(
                    leading: const Icon(Icons.schedule, color: Colors.white70),
                    title: const Text(
                      'Token Expires',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      _formatExpiry(conn.tokenExpiresAt!),
                      style: TextStyle(
                        color: _isTokenExpiringSoon(conn.tokenExpiresAt!)
                            ? Colors.orangeAccent
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),

                // Connection status
                ListTile(
                  leading: const Icon(Icons.sync, color: Colors.white70),
                  title: const Text(
                    'Worker',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    conn.pairingStatus.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: conn.daemonConnected
                          ? Colors.teal.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: conn.daemonConnected ? Colors.teal : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      conn.daemonConnected ? 'ONLINE' : 'OFFLINE',
                      style: TextStyle(
                        color: conn.daemonConnected
                            ? Colors.tealAccent
                            : Colors.redAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await TokenStore().clear();
                        SocketService().disconnect();
                        ref.read(connectionProvider.notifier).clearAll();
                        if (context.mounted) context.go('/pair');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.redAccent,
                      ),
                      icon: const Icon(Icons.link_off),
                      label: const Text('Disconnect & Re-pair'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Dependence Level ─────────────────────────────────────────
          _sectionHeader(theme, 'Agent Autonomy'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16161A),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: LevelPicker(
              currentLevel: session.dependenceLevel,
              onChanged: (level) {
                ref.read(sessionProvider.notifier).setLevel(level);
                actions.changeLevel(level);
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Notifications ───────────────────────────────────────────
          _sectionHeader(theme, 'System'),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF16161A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Push notifications',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Receive alerts when the agent needs approval or a task completes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  activeThumbColor: const Color(0xFF20B2AA),
                  value: notif.enabled,
                  onChanged: (v) =>
                      ref.read(notificationsProvider.notifier).setEnabled(v),
                ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'CodeTwin Version',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Text(
                    'v1.0.0 (Premium)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        RestartWidget.restartApp(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: Colors.redAccent.withValues(alpha: 0.6),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text('Restart'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF20B2AA),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  String _formatExpiry(int expiresAtMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  bool _isTokenExpiringSoon(int expiresAtMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    return dt.difference(DateTime.now()).inDays < 3;
  }
}
