/// go_router configuration with pairing redirect and shell navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/connection_provider.dart';
import 'providers/onboarding_provider.dart';
import 'models/session_status.dart';
import 'screens/pair_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/modals/preflight_modal.dart';
import 'screens/modals/decision_modal.dart';

// Keys are static — created once, never recreated. This prevents the
// "Duplicate GlobalKey" crash that occurs when routerProvider rebuilds
// and creates a new GoRouter with new keys on each connectionProvider change.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  // Use a Listenable so GoRouter re-evaluates redirect without being
  // recreated as a new object (which would cause GlobalKey conflicts).
  final notifier = _RouterRefreshNotifier(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final connState = ref.read(connectionProvider).valueOrNull;
      final isOnboarded = ref.read(onboardingProvider);
      final isPaired = connState?.isPaired == true;
      final isTokenExpired =
          connState?.pairingStatus == PairingStatus.tokenExpired;
      final loc = state.matchedLocation;

      if (!isOnboarded && loc != '/onboarding') return '/onboarding';
      if (isTokenExpired && loc != '/pair') return '/pair';
      if (isOnboarded && !isPaired && loc != '/pair') return '/pair';
      if (isPaired && (loc == '/pair' || loc == '/onboarding')) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/pair',
        builder: (_, __) => const PairScreen(),
      ),
      StatefulShellRoute(
        parentNavigatorKey: _rootNavigatorKey,
        navigatorContainerBuilder: (context, navigationShell, children) {
          return SwipeableShellContainer(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, shell) => ShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/logs',
              builder: (_, __) => const LogsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/history',
              builder: (_, __) => const HistoryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/modals/preflight',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => PreflightModal(
          awaitingResponseId: state.uri.queryParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/modals/decision',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => DecisionModal(
          awaitingResponseId: state.uri.queryParameters['id'] ?? '',
        ),
      ),
    ],
  );

  ref.onDispose(notifier.dispose);
  return router;
});

/// A [ChangeNotifier] that tells GoRouter to re-evaluate its redirect
/// when pairing/onboarding state changes — without recreating the GoRouter.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _sub1 = ref.listen(connectionProvider, (_, __) => notifyListeners());
    _sub2 = ref.listen(onboardingProvider, (_, __) => notifyListeners());
  }

  late final ProviderSubscription _sub1;
  late final ProviderSubscription _sub2;

  @override
  void dispose() {
    _sub1.close();
    _sub2.close();
    super.dispose();
  }
}
