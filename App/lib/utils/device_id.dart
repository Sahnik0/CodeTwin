/// Secure storage helpers for the device pairing credentials.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _deviceIdKey = 'CodeTwin_device_id';
const _signalingUrlKey = 'CodeTwin_signaling_url';

/// Persist the pairing info (deviceId + signaling URL) securely.
Future<void> savePairing(String deviceId, String signalingUrl) async {
  await _storage.write(key: _deviceIdKey, value: deviceId);
  await _storage.write(key: _signalingUrlKey, value: signalingUrl);
}

/// Load previously saved pairing, or `null` if none exists.
Future<({String deviceId, String signalingUrl})?> loadPairing() async {
  final deviceId = await _storage.read(key: _deviceIdKey);
  final signalingUrl = await _storage.read(key: _signalingUrlKey);
  if (deviceId == null || signalingUrl == null) return null;
  return (deviceId: deviceId, signalingUrl: signalingUrl);
}

/// Clear all pairing data (used when user re-pairs).
Future<void> clearPairing() async {
  await _storage.delete(key: _deviceIdKey);
  await _storage.delete(key: _signalingUrlKey);
}
