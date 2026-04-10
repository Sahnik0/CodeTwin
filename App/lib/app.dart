/// MaterialApp.router with Material 3 dark theme.
///
/// Bootstraps the connection state from saved credentials on first frame.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';
import 'providers/connection_provider.dart';
import 'services/token_store.dart';

class App extends ConsumerStatefulWidget {
  /// Credentials pre-loaded in main() from TokenStore. Null if not paired.
  final StoredCredentials? startupCreds;

  const App({super.key, this.startupCreds});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // Bootstrap connection state after the first frame so providers are ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  void _bootstrap() {
    final creds = widget.startupCreds;
    if (creds == null) return;

    final notifier = ref.read(connectionProvider.notifier);

    if (creds.isExpired) {
      notifier.initFromPairingResult(
        clientToken: creds.clientToken,
        pairingId: creds.pairingId,
        mobileDeviceId: creds.mobileDeviceId,
        tokenExpiresAt: creds.tokenExpiresAt,
        apiBaseUrl: creds.apiBaseUrl,
        wsUrl: creds.wsUrl,
      );
      notifier.markTokenExpired();
    } else {
      notifier.initFromPairingResult(
        clientToken: creds.clientToken,
        pairingId: creds.pairingId,
        mobileDeviceId: creds.mobileDeviceId,
        tokenExpiresAt: creds.tokenExpiresAt,
        apiBaseUrl: creds.apiBaseUrl,
        wsUrl: creds.wsUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use ref.read — the router handles its own redirect refreshes via
    // _RouterRefreshNotifier. Watching would recreate GoRouter on every
    // connectionProvider change, causing Duplicate GlobalKey crashes.
    final router = ref.read(routerProvider);

    return MaterialApp.router(
      title: 'CodeTwin',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
          surface: const Color(0xFF101014),
          onSurface: const Color(0xFFEBEBF5),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF16161A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF16161A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF08080A),
          indicatorColor: const Color(0xFF6C5CE7).withOpacity(0.2),
          elevation: 0,
        ),
      ),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      routerConfig: router,
    );
  }
}
