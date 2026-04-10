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

// Key for the shell navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final connection = ref.watch(connectionProvider);
  final isOnboarded = ref.watch(onboardingProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final connState = connection.valueOrNull;
      final isPaired = connState?.isPaired == true;
      final isTokenExpired =
          connState?.pairingStatus == PairingStatus.tokenExpired;
      final isGoingToPairPage = state.matchedLocation == '/pair';
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!isOnboarded && !isGoingToOnboarding) return '/onboarding';
      // Token expired → force re-pair
      if (isTokenExpired && !isGoingToPairPage) return '/pair';
      if (isOnboarded && !isPaired && !isGoingToPairPage) return '/pair';
      if (isPaired && (isGoingToPairPage || isGoingToOnboarding)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      // Redirect root appropriately (redirect logic catches it, defaults to dashboard)
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),

      // Onboarding screen
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // Pairing screen (outside shell)
      GoRoute(
        path: '/pair',
        builder: (_, __) => const PairScreen(),
      ),

      // Main app shell with bottom nav
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

      // Modals (pushed above the shell)
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
});
