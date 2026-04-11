/// Small connection status icon at the bottom right of the screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';
import '../providers/connection_provider.dart';
import '../services/socket_service.dart';

class DaemonStatusBar extends ConsumerStatefulWidget {
  const DaemonStatusBar({super.key});

  @override
  ConsumerState<DaemonStatusBar> createState() => _DaemonStatusBarState();
}

class _DaemonStatusBarState extends ConsumerState<DaemonStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connAsync = ref.watch(connectionProvider);
    final conn = connAsync.valueOrNull ?? DaemonConnectionState.empty;
    final isConnecting = conn.pairingStatus == PairingStatus.connecting;

    if (isConnecting) {
      if (!_spinController.isAnimating) {
        _spinController.repeat();
      }
    } else {
      if (_spinController.isAnimating) {
        _spinController.stop();
        _spinController.reset();
      }
    }

    final Color bg;
    final Color fg;
    final IconData icon;

    switch (conn.pairingStatus) {
      case PairingStatus.paired:
        bg = Colors.green.shade900;
        fg = Colors.white;
        icon = Icons.wifi;
        break;
      case PairingStatus.connecting:
        bg = Colors.blue.shade900;
        fg = Colors.white;
        icon = Icons.autorenew;
        break;
      default:
        bg = Colors.grey.shade900;
        fg = Colors.white;
        icon = Icons.wifi_off;
        break;
    }

    return GestureDetector(
      onTap: () {
        // Tap to reconnect — use clientToken not deviceId!
        final token = conn.clientToken;
        if (token != null && token.isNotEmpty && conn.wsUrl.isNotEmpty) {
          SocketService().disconnect();
          SocketService().connect(
            conn.wsUrl,
            token,
            mobileDeviceId: conn.mobileDeviceId ?? '',
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: fg.withValues(alpha: 0.8), width: 1.2),
        ),
        padding: const EdgeInsets.all(8),
        child: RotationTransition(
          turns: isConnecting
              ? _spinController
              : const AlwaysStoppedAnimation(0),
          child: Icon(icon, color: fg, size: 18),
        ),
      ),
    );
  }
}
