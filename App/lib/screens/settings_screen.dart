/// Settings screen — pairing info, level override, notifications, app version.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/connection_provider.dart';
import '../providers/session_provider.dart';
import '../providers/notifications_provider.dart';
import '../providers/daemon_actions_provider.dart';
import '../models/session_status.dart';
import '../widgets/level_picker.dart';
import '../utils/device_id.dart';
import '../services/socket_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _editingUrl = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conn = ref.watch(connectionProvider).valueOrNull ??
        DaemonConnectionState.empty;
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final notif =
        ref.watch(notificationsProvider).valueOrNull ??
        const NotificationsState();
    final actions = ref.read(daemonActionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ── Pairing ─────────────────────────────────────────────────
          _sectionHeader(theme, 'Pairing'),
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Device ID'),
            subtitle: Text(
              conn.deviceId ?? 'Not paired',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: const Text('Signaling URL'),
            subtitle: _editingUrl
                ? TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      isDense: true,
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final url = _urlController.text.trim();
                          if (url.isNotEmpty) {
                            ref
                                .read(connectionProvider.notifier)
                                .setSignalingUrl(url);
                            if (conn.deviceId != null) {
                              SocketService().connect(url, conn.deviceId!);
                            }
                          }
                          setState(() => _editingUrl = false);
                        },
                      ),
                    ),
                  )
                : Text(conn.signalingUrl),
            trailing: _editingUrl
                ? null
                : IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () {
                      _urlController.text = conn.signalingUrl;
                      setState(() => _editingUrl = true);
                    },
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Connection'),
            subtitle: Text(conn.pairingStatus.name),
            trailing: conn.daemonConnected
                ? const Chip(
                    label: Text('Online'),
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  )
                : const Chip(
                    label: Text('Offline'),
                    backgroundColor: Colors.grey,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                await clearPairing();
                SocketService().disconnect();
                ref
                    .read(connectionProvider.notifier)
                    .setPairingStatus(
                        PairingStatus.unpaired);
                if (context.mounted) context.go('/pair');
              },
              icon: const Icon(Icons.link_off),
              label: const Text('Re-pair'),
            ),
          ),

          const Divider(height: 32),

          // ── Dependence Level ─────────────────────────────────────────
          _sectionHeader(theme, 'Dependence Level'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LevelPicker(
              currentLevel: session.dependenceLevel,
              onChanged: (level) {
                ref.read(sessionProvider.notifier).setLevel(level);
                actions.changeLevel(level);
              },
            ),
          ),

          const Divider(height: 32),

          // ── Notifications ───────────────────────────────────────────
          _sectionHeader(theme, 'Notifications'),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text(
              'Receive alerts when the agent needs approval '
              'or a task completes.',
            ),
            value: notif.enabled,
            onChanged: (v) =>
                ref.read(notificationsProvider.notifier).setEnabled(v),
          ),

          const Divider(height: 32),

          // ── About ───────────────────────────────────────────────────
          _sectionHeader(theme, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CodeTwin'),
            subtitle: Text('v1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
