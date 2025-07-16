import 'package:flutter/material.dart';
import 'dart:math';
import 'pie_data_model.dart';

class PieChart extends StatefulWidget {
  final PieChartConfig config;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectionChanged;

  const PieChart({
    required this.config,
    this.selectedIndex,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  PiePainter? _painter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.config.animationDuration,
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        _painter = PiePainter(
          config: widget.config,
          progress: progress,
          selectedIndex: widget.selectedIndex,
        );

        return GestureDetector(
          onTapDown: (details) {
            if (_painter == null) return;

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
              // Si se toca el mismo segmento, deseleccionar
              final newSelection = touchedSegment == widget.selectedIndex
                  ? null
                  : touchedSegment;

              widget.onSelectionChanged?.call(newSelection);

              // Llamar callbacks originales
              widget.config.onTap?.call(touchedSegment);
              widget.config.onSegmentTap?.call(
                widget.config.data[touchedSegment],
              );
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

class PiePainter extends CustomPainter {
  final PieChartConfig config;
  final double progress;
  final int? selectedIndex;

  PiePainter({
    required this.config,
    this.progress = 1.0,
    this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = config.data.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;
    final holeRadius = config.spaceRadius / 2;

    double startAngle = -pi / 2;

    for (int i = 0; i < config.data.length; i++) {
      final segment = config.data[i];
      // Asegurar un círculo completo para un solo segmento
      final sweepAngle = config.data.length == 1
          ? 2 * pi * progress
          : 2 * pi * (segment.value / total) * progress;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      // Calculo del desplazamiento si es el segmento seleccionado
      final isSelected = i == selectedIndex;
      final offset = isSelected ? config.selectedOffset : 0.0;
      final offsetAngle = startAngle + sweepAngle / 2;
      final offsetCenter = Offset(
        center.dx + offset * cos(offsetAngle),
        center.dy + offset * sin(offsetAngle),
      );

      final path = Path();
      if (config.data.length == 1) {
        // Dibujar un anillo completo para un solo segmento
        path.addOval(Rect.fromCircle(center: offsetCenter, radius: radius));
      } else {
        path
          ..moveTo(offsetCenter.dx, offsetCenter.dy)
          ..arcTo(
            Rect.fromCircle(center: offsetCenter, radius: radius),
            startAngle,
            sweepAngle,
            false,
          )
          ..lineTo(offsetCenter.dx, offsetCenter.dy)
          ..close();
      }

      final holePath = Path()
        ..addOval(
          Rect.fromCircle(center: offsetCenter, radius: holeRadius),
        );

      final donutPath = Path.combine(PathOperation.difference, path, holePath);
      canvas.drawPath(donutPath, paint);

      if (progress > 0.8 && config.showPercentages) {
        final middleAngle = startAngle + sweepAngle / 2;
        final textRadius = (radius + holeRadius) / 2;
        final textX = offsetCenter.dx + textRadius * cos(middleAngle);
        final textY = offsetCenter.dy + textRadius * sin(middleAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${(segment.value / total * 100).toStringAsFixed(1)}%',
            style: config.percentageTextStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }

      if (config.showBorders) {
        final borderPaint = Paint()
          ..color = config.strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.strokeWidth;

        if (config.data.length == 1) {
          canvas.drawOval(
            Rect.fromCircle(center: offsetCenter, radius: radius),
            borderPaint,
          );
        } else {
          canvas.drawArc(
            Rect.fromCircle(center: offsetCenter, radius: radius),
            startAngle,
            sweepAngle,
            false,
            borderPaint,
          );
        }
      }

      startAngle += sweepAngle;
    }

    if (config.showBorders) {
      final innerBorderPaint = Paint()
        ..color = config.strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = config.strokeWidth;

      canvas.drawCircle(center, holeRadius, innerBorderPaint);
    }
  }

  int? getTouchedSegment(Offset position, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final holeRadius = config.spaceRadius / 2;

    final distance = (position - center).distance;
    if (distance < holeRadius || distance > radius + config.selectedOffset) {
      return null;
    }

    if (config.data.length == 1) {
      return 0; // Solo hay un segmento, siempre retornar 0
    }

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
  bool shouldRepaint(covariant PiePainter oldDelegate) {
    return oldDelegate.config != config ||
        oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
