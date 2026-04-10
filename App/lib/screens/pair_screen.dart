/// Pairing screen — enter server URL + pairing code from the CLI.
///
/// The CLI runs `codetwin login <serverUrl>` which displays a short
/// alphanumeric code such as `54NRW7GZ7YUX`. The user enters this code
/// here to complete the handshake via POST /pair/mobile/complete.
///
/// QR scanning is also supported: the CLI can optionally display a QR
/// whose JSON payload contains {"apiBaseUrl": "...", "code": "..."}.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../providers/connection_provider.dart';
import '../services/pairing_service.dart';
import '../services/socket_service.dart';
import '../services/token_store.dart';

class PairScreen extends ConsumerStatefulWidget {
  const PairScreen({super.key});

  @override
  ConsumerState<PairScreen> createState() => _PairScreenState();
}

class _PairScreenState extends ConsumerState<PairScreen> {
  bool _manualMode = false;
  bool _isConnecting = false;
  String? _errorMessage;

  final _codeController = TextEditingController();
  final _urlController = TextEditingController(
    text: 'https://codetwin-1quv.onrender.com',
  );
  final _formKey = GlobalKey<FormState>();

  static const _primaryColor = Color(0xFF20B2AA);

  @override
  void dispose() {
    _codeController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _completePairing(String apiBaseUrl, String code) async {
    setState(() {
      _isConnecting = true;
      _errorMessage = null;
    });

    try {
      final mobileDeviceId = const Uuid().v4();
      final result = await PairingService().completePairing(
        apiBaseUrl: apiBaseUrl,
        code: code,
        mobileDeviceId: mobileDeviceId,
        mobileDeviceName: 'CodeTwin Mobile',
      );

      // Persist credentials
      await TokenStore().save(result);

      // Update provider state
      ref.read(connectionProvider.notifier).initFromPairingResult(
            clientToken: result.clientToken,
            pairingId: result.pairingId,
            mobileDeviceId: result.mobileDeviceId,
            tokenExpiresAt: result.tokenExpiresAt,
            apiBaseUrl: result.apiBaseUrl,
            wsUrl: result.wsUrl,
          );

      // Connect WebSocket
      SocketService().connect(
        result.wsUrl,
        result.clientToken,
        mobileDeviceId: result.mobileDeviceId,
      );

      if (mounted) {
        context.go('/dashboard');
      }
    } on PairingException catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'Unexpected error: $e';
        });
      }
    }
  }

  void _onQrDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;

        // New QR format: {apiBaseUrl, code}
        final apiBaseUrl = json['apiBaseUrl'] as String?;
        final code = json['code'] as String?;
        if (apiBaseUrl != null && code != null) {
          _completePairing(apiBaseUrl, code);
          return;
        }

        // Legacy fallback: {signalingUrl, code} — map signalingUrl → apiBaseUrl
        final legacy = json['signalingUrl'] as String?;
        final legacyCode = json['code'] as String? ?? json['pairCode'] as String?;
        if (legacy != null && legacyCode != null) {
          // Convert wss:// → https:// for apiBaseUrl
          final httpBase = legacy
              .replaceFirst('wss://', 'https://')
              .replaceFirst('/ws', '');
          _completePairing(httpBase, legacyCode);
          return;
        }
      } catch (_) {
        // Not a valid CodeTwin QR — ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: _primaryColor,
          onPrimary: Colors.white,
          surface: Colors.black,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // ── Header ─────────────────────────────────────────────
                const Text(
                  'DEVICE PAIRING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect to CodeTwin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _manualMode
                      ? 'Run `codetwin login <server-url>` in your terminal,\nthen enter the code below.'
                      : 'Scan the QR code shown by the CLI\nor switch to manual code entry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                    height: 1.5,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Error Banner ────────────────────────────────────────
                if (_errorMessage != null)
                  _ErrorBanner(message: _errorMessage!),

                // ── Main Content ────────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutExpo,
                    switchOutCurve: Curves.easeInExpo,
                    child: _isConnecting
                        ? _buildConnectingState()
                        : (_manualMode
                            ? _buildManualForm()
                            : _buildQrScanner()),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mode Toggle ─────────────────────────────────────────
                if (!_isConnecting)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _manualMode = !_manualMode;
                          _errorMessage = null;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                              color: _primaryColor.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        _manualMode ? 'USE QR SCANNER' : 'ENTER CODE MANUALLY',
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Connecting state ────────────────────────────────────────────────────────

  Widget _buildConnectingState() {
    return Column(
      key: const ValueKey('connecting'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              backgroundColor: Color(0xFF20B2AA22),
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
              minHeight: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'PAIRING...',
          style: TextStyle(
            color: _primaryColor,
            fontSize: 14,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Contacting server',
          style: TextStyle(
            color: Colors.white.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ── QR scanner ──────────────────────────────────────────────────────────────

  Widget _buildQrScanner() {
    return Container(
      key: const ValueKey('qr'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: _primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            MobileScanner(onDetect: _onQrDetect),
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: _ScannerOverlayPainter(color: _primaryColor),
                    ),
                    _AnimatedScannerLaser(color: _primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Manual form ─────────────────────────────────────────────────────────────

  Widget _buildManualForm() {
    return SingleChildScrollView(
      key: const ValueKey('manual'),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Server URL field
            _buildField(
              controller: _urlController,
              label: 'SERVER URL',
              hint: 'https://codetwin-1quv.onrender.com',
              icon: Icons.cloud_outlined,
              keyboardType: TextInputType.url,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Server URL required';
                final uri = Uri.tryParse(v.trim());
                if (uri == null || !uri.hasScheme) return 'Enter a valid URL';
                if (!uri.scheme.startsWith('http')) {
                  return 'Use http:// or https://';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Pair code field
            _buildField(
              controller: _codeController,
              label: 'PAIRING CODE',
              hint: 'e.g. 54NRW7GZ7YUX',
              icon: Icons.vpn_key_outlined,
              textCapitalization: TextCapitalization.characters,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Pairing code required';
                if (v.trim().length < 4) return 'Code too short';
                return null;
              },
            ),
            const SizedBox(height: 36),

            // Connect button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _completePairing(
                      _urlController.text.trim(),
                      _codeController.text.trim().toUpperCase(),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'PAIR DEVICE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
          color: Colors.white, fontSize: 16, letterSpacing: 1.2),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
        labelStyle: TextStyle(
            color: _primaryColor.withOpacity(0.8),
            letterSpacing: 2.0,
            fontSize: 12),
        prefixIcon: Icon(icon, color: _primaryColor.withOpacity(0.8)),
        filled: true,
        fillColor: _primaryColor.withOpacity(0.05),
        errorStyle: const TextStyle(
            color: Colors.redAccent, letterSpacing: 1.0, fontSize: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: _primaryColor.withOpacity(0.2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
      ),
      validator: validator,
    );
  }
}

// ── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.redAccent, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR Overlay Painter ────────────────────────────────────────────────────────

class _ScannerOverlayPainter extends CustomPainter {
  final Color color;
  _ScannerOverlayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double l = 30.0;

    canvas.drawLine(Offset.zero, Offset(l, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, l), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - l, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, l), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(l, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - l), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - l, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - l), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Animated Scanner Laser ────────────────────────────────────────────────────

class _AnimatedScannerLaser extends StatefulWidget {
  final Color color;
  const _AnimatedScannerLaser({required this.color});

  @override
  State<_AnimatedScannerLaser> createState() => _AnimatedScannerLaserState();
}

class _AnimatedScannerLaserState extends State<_AnimatedScannerLaser>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 10 + (_animation.value * 198),
          left: 20,
          right: 20,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: widget.color,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
