import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DevGramLogo extends StatelessWidget {
  final double size;

  const DevGramLogo({super.key, this.size = 84});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CameraCodePainter(),
      ),
    );
  }
}

class _CameraCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gradient = LinearGradient(
      colors: AppTheme.accentGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    final bodyPaint = Paint()..shader = gradient;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.28, w * 0.92, h * 0.60),
      Radius.circular(w * 0.10),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    final flashRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.14, w * 0.40, h * 0.18),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(flashRect, bodyPaint);

    final lensCenter = Offset(w * 0.5, h * 0.60);
    final lensRadius = w * 0.27;
    canvas.drawCircle(
      lensCenter,
      lensRadius,
      Paint()..color = AppTheme.backgroundColor,
    );
    canvas.drawCircle(
      lensCenter,
      lensRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.015,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '</>',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.24,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        lensCenter.dx - textPainter.width / 2,
        lensCenter.dy - textPainter.height / 2,
      ),
    );

    canvas.drawCircle(
      Offset(w * 0.80, h * 0.40),
      w * 0.035,
      Paint()..color = Colors.white.withOpacity(0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
