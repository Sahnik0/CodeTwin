/// Pure Riverpod provider that wires SocketService events to ConnectionProvider.
///
/// Watch this provider once in app.dart or a top-level widget to activate it.
/// Being a provider (not a widget) avoids GlobalKey conflicts from wrapping
/// the Go Router StatefulNavigationShell in a StatefulWidget.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/socket_service.dart';
import '../models/bridge_event.dart';
import '../providers/connection_provider.dart';

final bridgeListenerProvider = Provider.autoDispose<void>((ref) {
  // Keep this provider alive for the full app session so callbacks
  // are never torn down by an intermediate rebuild.
  ref.keepAlive();

  final socket = SocketService();


  socket.onConnected = () {
    if (kDebugMode) debugPrint('[BridgeListener] WS connected → online');
    ref.read(connectionProvider.notifier)
      ..setAppConnected(true)
      ..setDaemonConnected(true);
  };

  socket.onDisconnected = () {
    if (kDebugMode) debugPrint('[BridgeListener] WS disconnected');
    ref.read(connectionProvider.notifier)
      ..setAppConnected(false)
      ..setDaemonConnected(false);
  };

  final cancelBridgeListener = socket.onBridgeEvent((event) {
    final notifier = ref.read(connectionProvider.notifier);
    switch (event.type) {
      case BridgeEventType.ready:
      case BridgeEventType.subscribed:
        notifier
          ..setAppConnected(true)
          ..setDaemonConnected(true);

      case BridgeEventType.exit:
        notifier.setLastPongAt(DateTime.now().toIso8601String());

      case BridgeEventType.error:
        final msg = event.message ?? '';
        if (kDebugMode) debugPrint('[BridgeListener] Bridge error: $msg');
        if (msg.contains('401') ||
            msg.contains('Unauthorized') ||
            msg.contains('expired')) {
          notifier.markTokenExpired();
        }

      default:
        break;
    }
  });

  // Sync immediately if already connected — deferred so Riverpod finishes
  // building this provider before we mutate connectionProvider.
  if (socket.isConnected) {
    Future.microtask(() {
      ref.read(connectionProvider.notifier)
        ..setAppConnected(true)
        ..setDaemonConnected(true);
    });
  }


  ref.onDispose(() {
    cancelBridgeListener();
    socket.onConnected = null;
    socket.onDisconnected = null;
  });
});
