/// Riverpod provider for daemon connection state.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class DaemonConnectionState {
  final String? deviceId;
  final String signalingUrl;
  final bool daemonConnected;
  final bool appConnected;
  final String? lastPongAt;
  final PairingStatus pairingStatus;

  const DaemonConnectionState({
    this.deviceId,
    this.signalingUrl = 'wss://signal.codetwin.dev',
    this.daemonConnected = false,
    this.appConnected = false,
    this.lastPongAt,
    this.pairingStatus = PairingStatus.unpaired,
  });

  static const empty = DaemonConnectionState();

  DaemonConnectionState copyWith({
    String? deviceId,
    String? signalingUrl,
    bool? daemonConnected,
    bool? appConnected,
    String? lastPongAt,
    PairingStatus? pairingStatus,
  }) {
    return DaemonConnectionState(
      deviceId: deviceId ?? this.deviceId,
      signalingUrl: signalingUrl ?? this.signalingUrl,
      daemonConnected: daemonConnected ?? this.daemonConnected,
      appConnected: appConnected ?? this.appConnected,
      lastPongAt: lastPongAt ?? this.lastPongAt,
      pairingStatus: pairingStatus ?? this.pairingStatus,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class ConnectionNotifier extends AsyncNotifier<DaemonConnectionState> {
  @override
  Future<DaemonConnectionState> build() async {
    return const DaemonConnectionState();
  }

  void setDeviceId(String id) {
    state = AsyncData(
      state.valueOrNull?.copyWith(deviceId: id) ??
          DaemonConnectionState(deviceId: id),
    );
  }

  void setSignalingUrl(String url) {
    state = AsyncData(
      state.valueOrNull?.copyWith(signalingUrl: url) ??
          DaemonConnectionState(signalingUrl: url),
    );
  }

  void setDaemonConnected(bool v) {
    state = AsyncData(
      state.valueOrNull?.copyWith(
            daemonConnected: v,
            pairingStatus: v ? PairingStatus.paired : PairingStatus.daemonOffline,
          ) ??
          DaemonConnectionState(daemonConnected: v),
    );
  }

  void setAppConnected(bool v) {
    state = AsyncData(
      state.valueOrNull?.copyWith(appConnected: v) ??
          DaemonConnectionState(appConnected: v),
    );
  }

  void setPairingStatus(PairingStatus s) {
    state = AsyncData(
      state.valueOrNull?.copyWith(pairingStatus: s) ??
          DaemonConnectionState(pairingStatus: s),
    );
  }

  void setLastPongAt(String timestamp) {
    state = AsyncData(
      state.valueOrNull?.copyWith(lastPongAt: timestamp) ??
          DaemonConnectionState(lastPongAt: timestamp),
    );
  }

  void initFromPairing(String deviceId, String signalingUrl) {
    state = AsyncData(DaemonConnectionState(
      deviceId: deviceId,
      signalingUrl: signalingUrl,
      pairingStatus: PairingStatus.connecting,
    ));
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final connectionProvider =
    AsyncNotifierProvider<ConnectionNotifier, DaemonConnectionState>(
  ConnectionNotifier.new,
);
