/// Handles the mobile side of the pairing handshake.
///
/// Calls POST /pair/mobile/complete with the user-entered pair code
/// and returns the full credential set required for WS + HTTP auth.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'token_store.dart';

/// Single trusted bridge endpoint used by the mobile app pairing flow.
const kCodeTwinApiBaseUrl = 'https://codetwin-1quv.onrender.com';

String normalizeApiBaseUrl(String url) {
  final parsed = Uri.tryParse(url.trim());
  if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) return '';
  return '${parsed.scheme}://${parsed.host}${parsed.hasPort ? ':${parsed.port}' : ''}';
}

class PairingException implements Exception {
  final String message;
  const PairingException(this.message);
  @override
  String toString() => 'PairingException: $message';
}

/// Result of a successful pairing handshake.
typedef PairingResult = StoredCredentials;

class PairingService {
  static final PairingService _instance = PairingService._internal();
  factory PairingService() => _instance;
  PairingService._internal();

  /// Complete pairing using a code shown by the CLI.
  ///
  /// [apiBaseUrl] — e.g. `https://codetwin-1quv.onrender.com`
  /// [code] — e.g. `54NRW7GZ7YUX`
  /// [mobileDeviceId] — a stable UUID identifying this phone
  /// [mobileDeviceName] — human-readable phone label
  Future<PairingResult> completePairing({
    required String apiBaseUrl,
    required String code,
    required String mobileDeviceId,
    String mobileDeviceName = 'CodeTwin App',
  }) async {
    final uri = Uri.parse('${_stripTrailingSlash(apiBaseUrl)}/pair/mobile/complete');
    if (kDebugMode) debugPrint('[PairingService] POST $uri');

    final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'code': code.trim().toUpperCase(),
              'mobileDeviceId': mobileDeviceId,
              'mobileDeviceName': mobileDeviceName,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on Exception catch (e) {
      throw PairingException('Network error: $e');
    }

    if (kDebugMode) {
      debugPrint('[PairingService] Response ${response.statusCode}: ${response.body}');
    }

    if (response.statusCode != 200) {
      String detail = '';
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        detail = body['error'] as String? ?? body['message'] as String? ?? '';
      } catch (_) {}
      throw PairingException(
        detail.isNotEmpty ? detail : 'Server returned ${response.statusCode}',
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const PairingException('Invalid JSON in server response');
    }

    final status = body['status'] as String?;
    if (status != 'paired') {
      throw PairingException('Unexpected status: $status');
    }

    // Extract and normalise wsUrl — guard against "wss://https://..." double prefix
    String wsUrl = body['wsUrl'] as String? ?? '';
    if (wsUrl.startsWith('wss://https://')) {
      wsUrl = wsUrl.replaceFirst('wss://https://', 'wss://');
    }
    if (wsUrl.startsWith('wss://http://')) {
      wsUrl = wsUrl.replaceFirst('wss://http://', 'ws://');
    }

    final clientToken = body['clientToken'] as String?;
    final pairingId = body['pairingId'] as String?;
    final returnedMobileDeviceId =
        body['mobileDeviceId'] as String? ?? mobileDeviceId;
    final tokenExpiresAt = body['tokenExpiresAt'] as int? ??
        DateTime.now()
            .add(const Duration(days: 30))
            .millisecondsSinceEpoch;
    final resolvedApiBaseUrl =
        body['apiBaseUrl'] as String? ?? apiBaseUrl;

    if (clientToken == null || pairingId == null) {
      throw const PairingException('Server response missing clientToken or pairingId');
    }

    return StoredCredentials(
      clientToken: clientToken,
      pairingId: pairingId,
      mobileDeviceId: returnedMobileDeviceId,
      tokenExpiresAt: tokenExpiresAt,
      apiBaseUrl: resolvedApiBaseUrl,
      wsUrl: wsUrl,
    );
  }
}

String _stripTrailingSlash(String s) =>
    s.endsWith('/') ? s.substring(0, s.length - 1) : s;
