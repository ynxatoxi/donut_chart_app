// deekseek_animate_chart.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'donut_chart_config.dart';

class DonutPainter extends CustomPainter {
  final DonutChartConfig config;
  final double progress;

  DonutPainter({required this.config, this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = config.data.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;
    final holeRadius = config.spaceRadius / 2;

    // Dibujar los segmentos
    double startAngle = -pi / 2;
    final double selectedOffset = 10;
    final selectedIndex = 0;
    for (int i = 0; i < config.data.length; i++) {
      final segment = config.data[i];
      final sweepAngle = 2 * pi * (segment.value / total) * progress;
      final paint =
          Paint()
            ..color = segment.color
            ..style = PaintingStyle.fill;

      // Calcular desplazamiento si es el segmento seleccionado
      final isSelected = i == selectedIndex;
      final offset = isSelected ? selectedOffset : 0.0;
      final offsetAngle = startAngle + sweepAngle / 2;
      final offsetCenter = Offset(
        center.dx + offset * cos(offsetAngle),
        center.dy + offset * sin(offsetAngle),
      );

      // Dibujar el segmento de la dona con posible desplazamiento
      final path =
          Path()
            ..moveTo(offsetCenter.dx, offsetCenter.dy)
            ..arcTo(
              Rect.fromCircle(center: offsetCenter, radius: radius),
              startAngle,
              sweepAngle,
              false,
            )
            ..lineTo(offsetCenter.dx, offsetCenter.dy)
            ..close();

      final holePath =
          Path()..addOval(
            Rect.fromCircle(center: offsetCenter, radius: holeRadius),
          );

      final donutPath = Path.combine(PathOperation.difference, path, holePath);

      canvas.drawPath(donutPath, paint);

      // Texto en los segmentos (opcional)
      if (progress > 0.8) {
        final middleAngle = startAngle + sweepAngle / 2;
        final textRadius = (radius + holeRadius) / 2;
        final textX = offsetCenter.dx + textRadius * cos(middleAngle);
        final textY = offsetCenter.dy + textRadius * sin(middleAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(segment.value / total * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      // Bordes de los segmentos
      final borderPaint =
          Paint()
            ..color = config.strokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = config.strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: offsetCenter, radius: radius),
        startAngle,
        sweepAngle,
        false,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Borde interior
    final innerBorderPaint =
        Paint()
          ..color = config.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.strokeWidth;

    canvas.drawCircle(center, holeRadius, innerBorderPaint);
  }

  void paint1(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = config.data.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;
    final holeRadius = config.spaceRadius / 2;

    // Dibujar los segmentos
    double startAngle = -pi / 2;

    for (var segment in config.data) {
      final sweepAngle = 2 * pi * (segment.value / total) * progress;
      final paint =
          Paint()
            ..color = segment.color
            ..style = PaintingStyle.fill;

      // Dibujar el segmento de la dona
      final path =
          Path()
            ..moveTo(center.dx, center.dy)
            ..arcTo(
              Rect.fromCircle(center: center, radius: radius),
              startAngle,
              sweepAngle,
              false,
            )
            ..lineTo(center.dx, center.dy)
            ..close();

      final holePath =
          Path()..addOval(Rect.fromCircle(center: center, radius: holeRadius));

      final donutPath = Path.combine(PathOperation.difference, path, holePath);

      canvas.drawPath(donutPath, paint);

      // Texto en los segmentos (opcional)
      if (progress > 0.8) {
        final middleAngle = startAngle + sweepAngle / 2;
        final textRadius = (radius + holeRadius) / 2;
        final textX = center.dx + textRadius * cos(middleAngle);
        final textY = center.dy + textRadius * sin(middleAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(segment.value / total * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      // Bordes de los segmentos
      final borderPaint =
          Paint()
            ..color = config.strokeColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = config.strokeWidth;

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
    final innerBorderPaint =
        Paint()
          ..color = config.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.strokeWidth;

    canvas.drawCircle(center, holeRadius, innerBorderPaint);
  }

  int? getTouchedSegment(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final holeRadius = config.spaceRadius / 2;

    final distance = (position - center).distance;
    if (distance < holeRadius || distance > radius) return null;

    final touchAngle = (position - center).direction;
    double normalizedAngle = (touchAngle + pi / 2) % (2 * pi);
    if (normalizedAngle < 0) normalizedAngle += 2 * pi;

    double startAngle = 0;
    final total = config.data.fold(0.0, (sum, segment) => sum + segment.value);

    for (int i = 0; i < config.data.length; i++) {
      final sweepAngle = 2 * pi * (config.data[i].value / total);
      if (normalizedAngle >= startAngle &&
          normalizedAngle <= startAngle + sweepAngle) {
        return i;
      }
      startAngle += sweepAngle;
    }

    return null;
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.config != config || oldDelegate.progress != progress;
  }
}

class InteractiveDonutChart extends StatefulWidget {
  final DonutChartConfig config;

  const InteractiveDonutChart({required this.config, super.key});

  @override
  State<InteractiveDonutChart> createState() => _InteractiveDonutChartState();
}

class _InteractiveDonutChartState extends State<InteractiveDonutChart> {
  DonutPainter? _painter;
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.config.animationDuration,
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        _painter = DonutPainter(config: widget.config, progress: progress);

        return GestureDetector(
          onTapDown: (details) {
            if (_painter == null || widget.config.onTap == null) return;

            final renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(
              details.globalPosition,
            );

            final touchedSegment = _painter!.getTouchedSegment(
              localPosition,
              Size(
                widget.config.spaceRadius * 2,
                widget.config.spaceRadius * 2,
              ),
            );

            if (touchedSegment != null) {
              widget.config.onTap!(touchedSegment);
              if (widget.config.onSegmentTap != null) {
                widget.config.onSegmentTap!(widget.config.data[touchedSegment]);
              }
            }
          },
          child: CustomPaint(
            size: Size(
              widget.config.spaceRadius * 2,
              widget.config.spaceRadius * 2,
            ),
            painter: _painter,
          ),
        );
      },
    );
  }
}
