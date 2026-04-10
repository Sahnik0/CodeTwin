/// Secure storage helpers for backward compatibility.
///
/// New code should use TokenStore directly. This shim wraps TokenStore
/// so existing call sites that used device_id.dart still compile.

import '../services/token_store.dart';

final _store = TokenStore();

/// Persist pairing info. Kept for backward compat — prefer TokenStore.save().
Future<void> savePairing(String mobileDeviceId, String wsUrl) async {
  // Only saves the two old fields; full save is done by PairingService flow.
  final existing = await _store.load();
  if (existing != null) {
    await _store.save(StoredCredentials(
      clientToken: existing.clientToken,
      pairingId: existing.pairingId,
      mobileDeviceId: mobileDeviceId,
      tokenExpiresAt: existing.tokenExpiresAt,
      apiBaseUrl: existing.apiBaseUrl,
      wsUrl: wsUrl,
    ));
  }
}

/// Load previously saved pairing info.
Future<({String deviceId, String signalingUrl})?> loadPairing() async {
  final creds = await _store.load();
  if (creds == null) return null;
  return (deviceId: creds.mobileDeviceId, signalingUrl: creds.wsUrl);
}

/// Clear all pairing data.
Future<void> clearPairing() => _store.clear();
