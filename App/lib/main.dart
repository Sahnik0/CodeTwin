/// CodeTwin app entry point.
///
/// On launch:
/// 1. Initialize notifications
/// 2. Load saved pairing credentials from secure storage (TokenStore)
/// 3. If credentials exist and haven't expired, auto-connect WebSocket
/// 4. If expired, the App widget marks token as expired → router redirects to /pair
/// 5. Run the app inside a Riverpod ProviderScope

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/notifications_service.dart';
import 'services/socket_service.dart';
import 'services/token_store.dart';
import 'providers/onboarding_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences BEFORE app starts
  final sharedPrefs = await SharedPreferences.getInstance();

  // Initialise local notifications
  await NotificationsService().init();
  await NotificationsService().requestPermission();

  // Load saved remote bridge credentials
  final creds = await TokenStore().load();

  // Track foreground/background for notification routing
  final lifecycleListener = AppLifecycleListener(
    onStateChange: (state) {
      final isForeground = state == AppLifecycleState.resumed;
      NotificationsService().setAppInForeground(isForeground);
    },
  );

  // If already paired and token is valid, auto-reconnect WebSocket
  if (creds != null && !creds.isExpired) {
    SocketService().connect(
      creds.wsUrl,
      creds.clientToken,
      mobileDeviceId: creds.mobileDeviceId,
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: App(startupCreds: creds),
    ),
  );

  // Keep the listener reference alive (avoid GC)
  // ignore: unused_local_variable
  final _ = lifecycleListener;
}
