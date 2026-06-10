import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class ConfidenceMeter extends StatelessWidget {
  final int confidence;
  final double size;
  final bool showLabel;

  const ConfidenceMeter({
    Key? key,
    required this.confidence,
    this.size = 80,
    this.showLabel = true,
  }) : super(key: key);

  Color get _color {
    if (confidence >= 85) return const Color(0xFF00FF88);
    if (confidence >= 75) return AppTheme.success;
    if (confidence >= 60) return const Color(0xFFF59E0B);
    return AppTheme.danger;
  }

  String get _label {
    if (confidence >= 85) return 'HIGH';
    if (confidence >= 75) return 'GOOD';
    if (confidence >= 60) return 'FAIR';
    return 'WEAK';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              progress: confidence / 100.0,
              color: _color,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$confidence',
                style: TextStyle(
                  color: _color,
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (showLabel)
                Text(
                  _label,
                  style: TextStyle(
                    color: _color.withOpacity(0.7),
                    fontSize: size * 0.11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const startAngle = pi * 0.75;
    const sweepMax = pi * 1.5;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweepMax, false, trackPaint);

    // Progress
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          center: Alignment.center,
          startAngle: startAngle,
          endAngle: startAngle + sweepMax * progress,
          colors: [color.withOpacity(0.5), color],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepMax * progress, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.progress != progress || old.color != color;
}

// Compact inline confidence bar for lists
class ConfidenceBar extends StatelessWidget {
  final int confidence;
  final double height;

  const ConfidenceBar({Key? key, required this.confidence, this.height = 4}) : super(key: key);

  Color get _color {
    if (confidence >= 85) return const Color(0xFF00FF88);
    if (confidence >= 75) return AppTheme.success;
    if (confidence >= 60) return const Color(0xFFF59E0B);
    return AppTheme.danger;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: confidence / 100.0,
        backgroundColor: Colors.white.withOpacity(0.08),
        valueColor: AlwaysStoppedAnimation<Color>(_color),
        minHeight: height,
      ),
    );
  }
}
