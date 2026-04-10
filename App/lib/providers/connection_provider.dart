/// Riverpod provider for daemon connection state.
///
/// Tracks the new remote bridge credentials (clientToken, pairingId,
/// apiBaseUrl, wsUrl) replacing the old direct-daemon signalingUrl/deviceId.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_status.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class DaemonConnectionState {
  /// UUID identifying this phone (returned by the server after pairing).
  final String? mobileDeviceId;

  /// Opaque pairing identifier from the server (links app ↔ CLI worker).
  final String? pairingId;

  /// JWT / signed token sent on every authenticated request.
  final String? clientToken;

  /// Token expiry timestamp (ms since epoch).
  final int? tokenExpiresAt;

  /// HTTP base URL of the remote bridge server.
  /// e.g. `https://codetwin-1quv.onrender.com`
  final String apiBaseUrl;

  /// WebSocket URL of the remote bridge server.
  /// e.g. `wss://codetwin-1quv.onrender.com/ws`
  final String wsUrl;

  /// True when the CLI worker has connected and the WS session is alive.
  final bool daemonConnected;

  /// True when the app WebSocket to the bridge is established.
  final bool appConnected;

  final String? lastPongAt;
  final PairingStatus pairingStatus;

  const DaemonConnectionState({
    this.mobileDeviceId,
    this.pairingId,
    this.clientToken,
    this.tokenExpiresAt,
    this.apiBaseUrl = '',
    this.wsUrl = '',
    this.daemonConnected = false,
    this.appConnected = false,
    this.lastPongAt,
    this.pairingStatus = PairingStatus.unpaired,
  });

  static const empty = DaemonConnectionState();

  /// Convenience: true when the app has a valid, non-expired clientToken.
  bool get isPaired =>
      clientToken != null &&
      clientToken!.isNotEmpty &&
      pairingStatus != PairingStatus.tokenExpired;

  /// Convenience: expose mobileDeviceId as `deviceId` for parts of the app
  /// that still use the old field name.
  String? get deviceId => mobileDeviceId;

  /// The "signaling URL" alias maps to wsUrl for backward compat.
  String get signalingUrl => wsUrl;

  DaemonConnectionState copyWith({
    String? mobileDeviceId,
    String? pairingId,
    String? clientToken,
    int? tokenExpiresAt,
    String? apiBaseUrl,
    String? wsUrl,
    bool? daemonConnected,
    bool? appConnected,
    String? lastPongAt,
    PairingStatus? pairingStatus,
  }) {
    return DaemonConnectionState(
      mobileDeviceId: mobileDeviceId ?? this.mobileDeviceId,
      pairingId: pairingId ?? this.pairingId,
      clientToken: clientToken ?? this.clientToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      wsUrl: wsUrl ?? this.wsUrl,
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

  DaemonConnectionState get _s =>
      state.valueOrNull ?? DaemonConnectionState.empty;

  /// Atomically initialise state from a successful pairing result.
  void initFromPairingResult({
    required String clientToken,
    required String pairingId,
    required String mobileDeviceId,
    required int tokenExpiresAt,
    required String apiBaseUrl,
    required String wsUrl,
  }) {
    state = AsyncData(DaemonConnectionState(
      clientToken: clientToken,
      pairingId: pairingId,
      mobileDeviceId: mobileDeviceId,
      tokenExpiresAt: tokenExpiresAt,
      apiBaseUrl: apiBaseUrl,
      wsUrl: wsUrl,
      pairingStatus: PairingStatus.connecting,
    ));
  }

  void setAppConnected(bool v) {
    state = AsyncData(_s.copyWith(
      appConnected: v,
      pairingStatus: v ? PairingStatus.paired : _s.pairingStatus,
    ));
  }

  void setDaemonConnected(bool v) {
    state = AsyncData(_s.copyWith(
      daemonConnected: v,
      pairingStatus:
          v ? PairingStatus.paired : PairingStatus.daemonOffline,
    ));
  }

  void setPairingStatus(PairingStatus s) {
    state = AsyncData(_s.copyWith(pairingStatus: s));
  }

  void setLastPongAt(String timestamp) {
    state = AsyncData(_s.copyWith(lastPongAt: timestamp));
  }

  void markTokenExpired() {
    state = AsyncData(
      _s.copyWith(pairingStatus: PairingStatus.tokenExpired),
    );
  }

  void clearAll() {
    state = const AsyncData(DaemonConnectionState.empty);
  }

  // ── Legacy shims kept for backward compat ───────────────────────────────

  /// Old code called this to start connecting after QR/manual pair.
  /// Now delegates to [initFromPairingResult].
  void initFromPairing(String mobileDeviceId, String wsUrl) {
    state = AsyncData(DaemonConnectionState(
      mobileDeviceId: mobileDeviceId,
      wsUrl: wsUrl,
      pairingStatus: PairingStatus.connecting,
    ));
  }

  void setDeviceId(String id) {
    state = AsyncData(_s.copyWith(mobileDeviceId: id));
  }

  void setSignalingUrl(String url) {
    // Old settings screen wrote to signalingUrl; map to wsUrl
    state = AsyncData(_s.copyWith(wsUrl: url));
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final connectionProvider =
    AsyncNotifierProvider<ConnectionNotifier, DaemonConnectionState>(
  ConnectionNotifier.new,
);
