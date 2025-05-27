import 'package:flutter/material.dart';
import 'dart:math';

class PieData {
  final String title;
  final double value;
  final Color color;

  PieData({
    required this.title,
    required this.value,
    required this.color,
  });
}

class AnimatedDonutChart extends StatefulWidget {
  final List<PieData> segments;
  final double diameter;
  final double holeDiameter;
  final TextStyle textStyle;
  final Duration duration;

  const AnimatedDonutChart({
    required this.segments,
    required this.diameter,
    required this.holeDiameter,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    this.duration = const Duration(milliseconds: 1000),
    super.key,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.duration,
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        return CustomPaint(
          size: Size(widget.diameter, widget.diameter),
          painter: DonutPainter(
            segments: widget.segments,
            holeRadius: widget.holeDiameter / 2,
            textStyle: widget.textStyle,
            progress: progress,
          ),
        );
      },
    );
  }
}

class DonutPainter extends CustomPainter {
  final List<PieData> segments;
  final double holeRadius;
  final TextStyle textStyle;
  final double progress;

  DonutPainter({
    required this.segments,
    required this.holeRadius,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = segments.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;

    // Dibujar los segmentos
    double startAngle = -pi / 2; // Comenzar desde la parte superior

    for (var segment in segments) {
      final sweepAngle = 2 * pi * (segment.value / total) * progress;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      // Dibujar el segmento de la dona
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();

      final holePath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: holeRadius));
      
      final donutPath = Path.combine(
        PathOperation.difference,
        path,
        holePath,
      );

      canvas.drawPath(donutPath, paint);

      // Calcular posición para el texto (solo cuando la animación está casi completa)
      if (progress > 0.8) {
        final middleAngle = startAngle + sweepAngle / 2;
        final textRadius = (radius + holeRadius) / 2;
        final textX = center.dx + textRadius * cos(middleAngle);
        final textY = center.dy + textRadius * sin(middleAngle);

        // Dibujar el porcentaje
        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(segment.value / total * 100).toStringAsFixed(1)}%',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      // Dibujar bordes
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Borde interior
    final innerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, holeRadius, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.holeRadius != holeRadius ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.progress != progress;
  }
}