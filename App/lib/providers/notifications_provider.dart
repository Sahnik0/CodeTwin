/// Riverpod provider for local notification permission state.

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class NotificationsState {
  final bool permissionGranted;
  final bool enabled;

  const NotificationsState({
    this.permissionGranted = false,
    this.enabled = true,
  });

  NotificationsState copyWith({
    bool? permissionGranted,
    bool? enabled,
  }) {
    return NotificationsState(
      permissionGranted: permissionGranted ?? this.permissionGranted,
      enabled: enabled ?? this.enabled,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class NotificationsNotifier extends AsyncNotifier<NotificationsState> {
  @override
  Future<NotificationsState> build() async {
    return const NotificationsState();
  }

  void setPermissionGranted(bool v) {
    state = AsyncData(
      state.valueOrNull?.copyWith(permissionGranted: v) ??
          NotificationsState(permissionGranted: v),
    );
  }

  void setEnabled(bool v) {
    state = AsyncData(
      state.valueOrNull?.copyWith(enabled: v) ??
          NotificationsState(enabled: v),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
