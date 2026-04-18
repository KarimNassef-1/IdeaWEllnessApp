import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_session_confirmation_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  static const Color _accentOrange = Color(0xFFF7931A);
  final MobileScannerController _controller = MobileScannerController(
    autoStart: true,
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  bool _handled = false;
  bool _torchOn = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    if (!mounted) return;
    setState(() => _torchOn = !_torchOn);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    _handled = true;
    await _controller.stop();
    HapticFeedback.vibrate();
    if (!mounted) return;
    setState(() => _showSuccess = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QrSessionConfirmationScreen(scannedCode: code),
      ),
    );

    if (!mounted) return;
    setState(() {
      _showSuccess = false;
      _handled = false;
    });
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lensSize = (size.width * 0.72).clamp(240.0, 320.0);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _ScannerOverlay(lensSize: lensSize, accentColor: _accentOrange),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset('img/idea-app-icon.png', width: 48, height: 48),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Heliopolis Branch - Check-In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: _GlassCircleButton(
                      icon: Icons.close_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
              child: Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Align the QR code within the frame to check-in.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _GlassCircleButton(
                        icon: _torchOn ? Icons.flashlight_off_rounded : Icons.flashlight_on_rounded,
                        onTap: _toggleTorch,
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: AnimatedOpacity(
                opacity: _showSuccess ? 1 : 0,
                duration: const Duration(milliseconds: 230),
                child: AnimatedScale(
                  scale: _showSuccess ? 1 : 0.85,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7931A).withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 62),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay({required this.lensSize, required this.accentColor});

  final double lensSize;
  final Color accentColor;

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lensRadius = BorderRadius.circular(24);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final lensLeft = (constraints.maxWidth - widget.lensSize) / 2;
          final lensTop = (constraints.maxHeight - widget.lensSize) / 2;
          final lensRect = Rect.fromLTWH(lensLeft, lensTop, widget.lensSize, widget.lensSize);

          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _LensMaskPainter(lensRect: lensRect),
              ),
              Positioned.fromRect(
                rect: lensRect,
                child: _ViewfinderCorners(accentColor: widget.accentColor),
              ),
              Positioned.fromRect(
                rect: lensRect,
                child: ClipRRect(
                  borderRadius: lensRadius,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Align(
                        alignment: Alignment(0, -1 + (_controller.value * 2)),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          height: 2.5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: widget.accentColor,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withValues(alpha: 0.8),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LensMaskPainter extends CustomPainter {
  const _LensMaskPainter({required this.lensRect});

  final Rect lensRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x99000000)
      ..style = PaintingStyle.fill;

    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(lensRect, const Radius.circular(24)));

    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cutout),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LensMaskPainter oldDelegate) =>
      oldDelegate.lensRect != lensRect;
}

class _ViewfinderCorners extends StatelessWidget {
  const _ViewfinderCorners({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ViewfinderCornerPainter(accentColor: accentColor),
      size: Size.infinite,
    );
  }
}

class _ViewfinderCornerPainter extends CustomPainter {
  const _ViewfinderCornerPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLen = 34.0;
    const offset = 8.0;
    const curveRadius = 24.0;

    final left = offset;
    final top = offset;
    final right = size.width - offset;
    final bottom = size.height - offset;

    final topLeft = Path()
      ..moveTo(left + cornerLen, top)
      ..lineTo(left + curveRadius, top)
      ..quadraticBezierTo(left, top, left, top + curveRadius)
      ..lineTo(left, top + cornerLen);

    final topRight = Path()
      ..moveTo(right - cornerLen, top)
      ..lineTo(right - curveRadius, top)
      ..quadraticBezierTo(right, top, right, top + curveRadius)
      ..lineTo(right, top + cornerLen);

    final bottomLeft = Path()
      ..moveTo(left, bottom - cornerLen)
      ..lineTo(left, bottom - curveRadius)
      ..quadraticBezierTo(left, bottom, left + curveRadius, bottom)
      ..lineTo(left + cornerLen, bottom);

    final bottomRight = Path()
      ..moveTo(right - cornerLen, bottom)
      ..lineTo(right - curveRadius, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - curveRadius)
      ..lineTo(right, bottom - cornerLen);

    canvas.drawPath(topLeft, paint);
    canvas.drawPath(topRight, paint);
    canvas.drawPath(bottomLeft, paint);
    canvas.drawPath(bottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderCornerPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withValues(alpha: 0.16),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
