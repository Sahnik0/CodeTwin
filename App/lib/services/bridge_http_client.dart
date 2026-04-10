/// Authenticated HTTP client for the CodeTwin remote bridge REST API.
///
/// All calls include `Authorization: Bearer <clientToken>`.
/// Use this for job creation, job queries, and stdin/terminate.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BridgeHttpException implements Exception {
  final int? statusCode;
  final String message;
  const BridgeHttpException(this.message, {this.statusCode});
  @override
  String toString() => 'BridgeHttpException($statusCode): $message';
}

/// Returned by job-creation endpoints.
class JobRef {
  final String id;
  final String? workerId;
  final String status;
  final String mode;

  const JobRef({
    required this.id,
    this.workerId,
    required this.status,
    required this.mode,
  });

  factory JobRef.fromJson(Map<String, dynamic> json) {
    return JobRef(
      id: json['id'] as String,
      workerId: json['workerId'] as String?,
      status: json['status'] as String? ?? 'pending',
      mode: json['mode'] as String? ?? 'shell',
    );
  }
}

class BridgeHttpClient {
  String _apiBaseUrl;
  String _clientToken;

  BridgeHttpClient({required String apiBaseUrl, required String clientToken})
      : _apiBaseUrl = _stripTrailingSlash(apiBaseUrl),
        _clientToken = clientToken;

  void update({required String apiBaseUrl, required String clientToken}) {
    _apiBaseUrl = _stripTrailingSlash(apiBaseUrl);
    _clientToken = clientToken;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_clientToken',
      };

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_apiBaseUrl$path');
    if (kDebugMode) debugPrint('[BridgeHttp] GET $uri');
    final resp = await http.get(uri, headers: _headers)
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_apiBaseUrl$path');
    if (kDebugMode) debugPrint('[BridgeHttp] POST $uri body=$body');
    final resp = await http
        .post(uri, headers: _headers, body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }

  Map<String, dynamic> _parse(http.Response resp) {
    if (kDebugMode) {
      debugPrint('[BridgeHttp] ${resp.statusCode} ${resp.body.length}b');
    }
    if (resp.statusCode == 401) {
      throw const BridgeHttpException('Unauthorized — token invalid or expired',
          statusCode: 401);
    }
    if (resp.statusCode == 403) {
      throw const BridgeHttpException('Forbidden — wrong token role',
          statusCode: 403);
    }
    if (resp.statusCode >= 400) {
      String detail = '';
      try {
        final b = jsonDecode(resp.body) as Map<String, dynamic>;
        detail = b['error'] as String? ?? b['message'] as String? ?? '';
      } catch (_) {}
      throw BridgeHttpException(
        detail.isNotEmpty ? detail : 'HTTP ${resp.statusCode}',
        statusCode: resp.statusCode,
      );
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ── API surface ──────────────────────────────────────────────────────────

  /// GET /pair/config — verify the server is reachable and config is valid.
  Future<Map<String, dynamic>> getPairConfig() => _get('/pair/config');

  /// GET /jobs — list all jobs for this pairing.
  Future<List<dynamic>> listJobs() async {
    final body = await _get('/jobs');
    return body['jobs'] as List<dynamic>? ?? [];
  }

  /// POST /jobs — execute a shell command.
  Future<JobRef> executeShell({
    required String command,
    String? cwd,
    Map<String, String>? env,
  }) async {
    final body = await _post('/jobs', {
      'command': command,
      if (cwd != null) 'cwd': cwd,
      if (env != null) 'env': env,
    });
    return JobRef.fromJson(body['job'] as Map<String, dynamic>);
  }

  /// POST /cli/exec — execute a codetwin CLI sub-command.
  Future<JobRef> cliExec({
    required List<String> args,
    String? cwd,
    Map<String, String>? env,
  }) async {
    final body = await _post('/cli/exec', {
      'args': args,
      if (cwd != null) 'cwd': cwd,
      if (env != null) 'env': env,
    });
    return JobRef.fromJson(body['job'] as Map<String, dynamic>);
  }

  /// GET /jobs/:id — fetch job details and accumulated logs.
  Future<Map<String, dynamic>> getJob(String jobId) =>
      _get('/jobs/$jobId');

  /// POST /jobs/:id/input — send stdin to a running job.
  Future<void> sendInput(
    String jobId,
    String text, {
    bool appendNewline = true,
  }) async {
    await _post('/jobs/$jobId/input', {
      'text': text,
      'appendNewline': appendNewline,
    });
  }

  /// POST /jobs/:id/terminate — send a signal to a running job.
  Future<void> terminateJob(String jobId, {String signal = 'SIGTERM'}) async {
    await _post('/jobs/$jobId/terminate', {'signal': signal});
  }
}

String _stripTrailingSlash(String s) =>
    s.endsWith('/') ? s.substring(0, s.length - 1) : s;
