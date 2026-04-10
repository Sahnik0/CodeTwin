/// Secure storage for all remote bridge pairing credentials.
///
/// This replaces the old device_id.dart helpers and stores the full
/// credential set returned by POST /pair/mobile/complete.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

const _kClientToken = 'ct_client_token';
const _kPairingId = 'ct_pairing_id';
const _kMobileDeviceId = 'ct_mobile_device_id';
const _kTokenExpiresAt = 'ct_token_expires_at';
const _kApiBaseUrl = 'ct_api_base_url';
const _kWsUrl = 'ct_ws_url';

/// All credentials returned after a successful pairing.
class StoredCredentials {
  final String clientToken;
  final String pairingId;
  final String mobileDeviceId;
  final int tokenExpiresAt; // ms since epoch
  final String apiBaseUrl;
  final String wsUrl;

  const StoredCredentials({
    required this.clientToken,
    required this.pairingId,
    required this.mobileDeviceId,
    required this.tokenExpiresAt,
    required this.apiBaseUrl,
    required this.wsUrl,
  });

  /// True when the token has passed its expiry timestamp.
  bool get isExpired =>
      DateTime.now().millisecondsSinceEpoch > tokenExpiresAt;
}

class TokenStore {
  static final TokenStore _instance = TokenStore._internal();
  factory TokenStore() => _instance;
  TokenStore._internal();

  /// Persist credentials from a successful pairing response.
  Future<void> save(StoredCredentials creds) async {
    await Future.wait([
      _storage.write(key: _kClientToken, value: creds.clientToken),
      _storage.write(key: _kPairingId, value: creds.pairingId),
      _storage.write(key: _kMobileDeviceId, value: creds.mobileDeviceId),
      _storage.write(
          key: _kTokenExpiresAt, value: creds.tokenExpiresAt.toString()),
      _storage.write(key: _kApiBaseUrl, value: creds.apiBaseUrl),
      _storage.write(key: _kWsUrl, value: creds.wsUrl),
    ]);
  }

  /// Load saved credentials, or `null` if none exist.
  Future<StoredCredentials?> load() async {
    final results = await Future.wait([
      _storage.read(key: _kClientToken),
      _storage.read(key: _kPairingId),
      _storage.read(key: _kMobileDeviceId),
      _storage.read(key: _kTokenExpiresAt),
      _storage.read(key: _kApiBaseUrl),
      _storage.read(key: _kWsUrl),
    ]);

    final clientToken = results[0];
    final pairingId = results[1];
    final mobileDeviceId = results[2];
    final tokenExpiresAtStr = results[3];
    final apiBaseUrl = results[4];
    final wsUrl = results[5];

    if (clientToken == null ||
        pairingId == null ||
        mobileDeviceId == null ||
        tokenExpiresAtStr == null ||
        apiBaseUrl == null ||
        wsUrl == null) {
      return null;
    }

    return StoredCredentials(
      clientToken: clientToken,
      pairingId: pairingId,
      mobileDeviceId: mobileDeviceId,
      tokenExpiresAt: int.tryParse(tokenExpiresAtStr) ?? 0,
      apiBaseUrl: apiBaseUrl,
      wsUrl: wsUrl,
    );
  }

  /// Remove all stored credentials (used when user disconnects / re-pairs).
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _kClientToken),
      _storage.delete(key: _kPairingId),
      _storage.delete(key: _kMobileDeviceId),
      _storage.delete(key: _kTokenExpiresAt),
      _storage.delete(key: _kApiBaseUrl),
      _storage.delete(key: _kWsUrl),
    ]);
  }
}
