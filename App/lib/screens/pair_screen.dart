/// Pairing screen — QR scan + manual entry.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/connection_provider.dart';
import '../services/socket_service.dart';
import '../utils/device_id.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  bool _manualMode = false;
  bool _isConnecting = false;
  final _deviceIdController = TextEditingController();
  final _urlController =
      TextEditingController(text: 'wss://signal.codetwin.dev');
  final _formKey = GlobalKey<FormState>();
  final _deviceIdPattern = RegExp(r'^[0-9a-f]{12}$');

  @override
  void dispose() {
    _deviceIdController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pair(String deviceId, String signalingUrl) async {
    setState(() => _isConnecting = true);

    await savePairing(deviceId, signalingUrl);
    ref.read(connectionProvider.notifier).initFromPairing(
          deviceId,
          signalingUrl,
        );
    SocketService().connect(signalingUrl, deviceId);

    if (mounted) {
      context.go('/dashboard');
    }
  }

  void _onQrDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final deviceId = json['deviceId'] as String?;
        final signalingUrl = json['signalingUrl'] as String?;
        if (deviceId != null && signalingUrl != null) {
          _pair(deviceId, signalingUrl);
          return;
        }
      } catch (_) {
        // Not a valid CodeTwin QR — ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.link, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Pair with CodeTwin',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scan the QR code shown by "codetwin connect" '
                'or enter the pairing info manually.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 32),

              if (_isConnecting) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Connecting…',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ] else if (_manualMode) ...[
                _buildManualForm(theme),
              ] else ...[
                _buildQrScanner(theme),
              ],

              const Spacer(),

              // Toggle mode
              if (!_isConnecting)
                TextButton(
                  onPressed: () =>
                      setState(() => _manualMode = !_manualMode),
                  child: Text(
                    _manualMode
                        ? 'Scan QR code instead'
                        : 'Enter pairing info manually',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrScanner(ThemeData theme) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: MobileScanner(onDetect: _onQrDetect),
      ),
    );
  }

  Widget _buildManualForm(ThemeData theme) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _deviceIdController,
            decoration: const InputDecoration(
              labelText: 'Device ID',
              hintText: '12-character hex string',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fingerprint),
            ),
            validator: (v) {
              if (v == null || !_deviceIdPattern.hasMatch(v)) {
                return 'Must be a 12-character hex string (0-9, a-f)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Signaling URL',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cloud),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'URL required';
              final uri = Uri.tryParse(v);
              if (uri == null || !uri.hasScheme) return 'Invalid URL';
              return null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _pair(
                  _deviceIdController.text.trim(),
                  _urlController.text.trim(),
                );
              }
            },
            icon: const Icon(Icons.link),
            label: const Text('Pair'),
          ),
        ],
      ),
    );
  }
}
