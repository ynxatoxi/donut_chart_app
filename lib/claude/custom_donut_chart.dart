// custom_donut_chart.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'donut_chart_config.dart';

class CustomDonutChart extends StatefulWidget {
  final DonutChartConfig config;

  const CustomDonutChart({required this.config, super.key});

  @override
  State<CustomDonutChart> createState() => _CustomDonutChartState();
}

class _CustomDonutChartState extends State<CustomDonutChart> {
  PieData? _selectedSegment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.backgroundColor,
      padding: widget.config.padding,
      child: Column(
        children: [
          if (widget.config.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                widget.config.title,
                style:
                    widget.config.titleStyle ??
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapDown:
                    widget.config.enableSegmentTapping ? _handleTapDown : null,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: widget.config.animationDuration,
                  curve: Curves.easeInOut,
                  builder: (context, progress, child) {
                    return CustomPaint(
                      size: Size(
                        widget.config.chartDiameter,
                        widget.config.chartDiameter,
                      ),
                      painter: DonutPainter(
                        segments: widget.config.data,
                        holeRadius: widget.config.holeDiameter / 2,
                        textStyle:
                            widget.config.segmentLabelStyle ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                        progress: progress,
                        showPercentages: widget.config.showPercentages,
                        thickness: widget.config.thickness,
                        selectedSegment: _selectedSegment,
                        selectedBorderColor:
                            widget.config.selectedSegmentBorderColor,
                        selectedBorderWidth:
                            widget.config.selectedSegmentBorderWidth,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (widget.config.showLegend)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: _buildLegend(),
            ),
        ],
      ),
    );
  }

  void _handleTapDown(TapDownDetails details) {
    // Obtener la posición relativa al centro del círculo
    final Size size = Size(
      widget.config.chartDiameter,
      widget.config.chartDiameter,
    );
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Offset localPosition = details.localPosition;

    // Calcular la distancia desde el centro
    final double dx = localPosition.dx - center.dx;
    final double dy = localPosition.dy - center.dy;
    final double distance = sqrt(dx * dx + dy * dy);

    // Verificar si el toque está dentro del anillo (no en el agujero y no fuera del círculo)
    final double outerRadius = size.width / 2;
    final double innerRadius = widget.config.holeDiameter / 2;

    if (distance >= innerRadius && distance <= outerRadius) {
      // Calcular el ángulo del toque (en radianes)
      double angle = atan2(dy, dx);
      // Ajustar el ángulo para que comience desde la parte superior (-π/2)
      if (angle < 0) {
        angle += 2 * pi;
      }
      angle = (angle + (3 * pi / 2)) % (2 * pi);

      // Encontrar el segmento correspondiente al ángulo
      double total = widget.config.data.fold(
        0.0,
        (sum, segment) => sum + segment.value,
      );
      double startAngle = 0;

      for (var segment in widget.config.data) {
        final sweepAngle = 2 * pi * (segment.value / total);
        final endAngle = startAngle + sweepAngle;

        if (angle >= startAngle && angle < endAngle) {
          setState(() {
            if (_selectedSegment == segment) {
              // Si ya está seleccionado, deseleccionar
              _selectedSegment = null;
            } else {
              _selectedSegment = segment;
            }
          });

          // Notificar al callback si existe
          if (widget.config.onSegmentTap != null) {
            widget.config.onSegmentTap!(segment);
          }
          break;
        }

        startAngle = endAngle;
      }
    }
  }

  Widget _buildLegend() {
    return Align(
      alignment: widget.config.legendAlignment,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: widget.config.legendSpacing,
        runSpacing: widget.config.legendSpacing,
        children:
            widget.config.data.map((segment) {
              final bool isSelected = _selectedSegment == segment;
              return GestureDetector(
                onTap:
                    widget.config.enableSegmentTapping
                        ? () {
                          setState(() {
                            if (_selectedSegment == segment) {
                              _selectedSegment = null;
                            } else {
                              _selectedSegment = segment;
                            }
                          });
                          if (widget.config.onSegmentTap != null) {
                            widget.config.onSegmentTap!(segment);
                          }
                        }
                        : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape: _getLegendShape(),
                        border:
                            isSelected
                                ? Border.all(
                                  color:
                                      widget
                                          .config
                                          .selectedSegmentBorderColor ??
                                      Colors.yellow,
                                  width: 2,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getLegendText(segment),
                      style:
                          widget.config.legendStyle ??
                          const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  BoxShape _getLegendShape() {
    switch (widget.config.legendShape) {
      case LegendShape.circle:
        return BoxShape.circle;
      case LegendShape.square:
      case LegendShape.rectangle:
      case LegendShape.roundedRectangle:
        return BoxShape.rectangle;
    }
  }

  Widget _buildLegendIcon(Color color, bool isSelected) {
    final decoration = BoxDecoration(
      color: color,
      border:
          isSelected
              ? Border.all(
                color:
                    widget.config.selectedSegmentBorderColor ?? Colors.yellow,
                width: 2,
              )
              : null,
    );

    switch (widget.config.legendShape) {
      case LegendShape.circle:
        return Container(
          width: 16,
          height: 16,
          decoration: decoration.copyWith(shape: BoxShape.circle),
        );
      case LegendShape.square:
        return Container(width: 16, height: 16, decoration: decoration);
      case LegendShape.rectangle:
        return Container(width: 24, height: 12, decoration: decoration);
      case LegendShape.roundedRectangle:
        return Container(
          width: 24,
          height: 12,
          decoration: decoration.copyWith(
            borderRadius: BorderRadius.circular(4),
          ),
        );
    }
  }

  String _getLegendText(PieData segment) {
    if (widget.config.legendFormat != null) {
      return widget.config.legendFormat!(segment);
    }

    // Calculate percentage
    final total = widget.config.data.fold(0.0, (sum, s) => sum + s.value);
    final percentage = (segment.value / total * 100).toStringAsFixed(1);

    return '${segment.title} ($percentage%)';
  }
}

class DonutPainter extends CustomPainter {
  final List<PieData> segments;
  final double holeRadius;
  final TextStyle textStyle;
  final double progress;
  final bool showPercentages;
  final double thickness;
  final PieData? selectedSegment;
  final Color? selectedBorderColor;
  final double selectedBorderWidth;

  DonutPainter({
    required this.segments,
    required this.holeRadius,
    required this.textStyle,
    this.progress = 1.0,
    this.showPercentages = true,
    this.thickness = 40,
    this.selectedSegment,
    this.selectedBorderColor = Colors.yellow,
    this.selectedBorderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = segments.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;
    final effectiveHoleRadius =
        holeRadius < radius - thickness ? holeRadius : radius - thickness;

    // Dibujar los segmentos
    double startAngle = -pi / 2; // Comenzar desde la parte superior
    List<_SegmentProperties> segmentProps = [];

    for (var segment in segments) {
      final sweepAngle = 2 * pi * (segment.value / total) * progress;
      final paint =
          Paint()
            ..color = segment.color
            ..style = PaintingStyle.fill;

      // Guardar propiedades del segmento para poder dibujarlo en orden (seleccionado último)
      segmentProps.add(
        _SegmentProperties(
          segment: segment,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          isSelected: segment == selectedSegment,
        ),
      );

      startAngle += sweepAngle;
    }

    // Primero dibujar segmentos no seleccionados
    for (var prop in segmentProps.where((p) => !p.isSelected)) {
      _drawSegment(canvas, size, center, radius, effectiveHoleRadius, prop);
    }

    // Luego dibujar el segmento seleccionado (para que esté encima)
    for (var prop in segmentProps.where((p) => p.isSelected)) {
      _drawSegment(canvas, size, center, radius, effectiveHoleRadius, prop);
    }

    // Borde interior
    final innerBorderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, effectiveHoleRadius, innerBorderPaint);
  }

  void _drawSegment(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    double effectiveHoleRadius,
    _SegmentProperties prop,
  ) {
    final paint =
        Paint()
          ..color = prop.segment.color
          ..style = PaintingStyle.fill;

    // Dibujar el segmento de la dona
    final path =
        Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(
            Rect.fromCircle(center: center, radius: radius),
            prop.startAngle,
            prop.sweepAngle,
            false,
          )
          ..lineTo(center.dx, center.dy)
          ..close();

    final holePath =
        Path()..addOval(
          Rect.fromCircle(center: center, radius: effectiveHoleRadius),
        );

    final donutPath = Path.combine(PathOperation.difference, path, holePath);

    canvas.drawPath(donutPath, paint);

    // Calcular posición para el texto (solo cuando la animación está casi completa)
    if (showPercentages && progress > 0.8) {
      final middleAngle = prop.startAngle + prop.sweepAngle / 2;
      final textRadius = (radius + effectiveHoleRadius) / 2;
      final textX = center.dx + textRadius * cos(middleAngle);
      final textY = center.dy + textRadius * sin(middleAngle);

      // Calcular porcentaje
      final total = segments.fold(0.0, (sum, segment) => sum + segment.value);
      final percentage = (prop.segment.value / total * 100).toStringAsFixed(1);

      // Dibujar el porcentaje
      final textPainter = TextPainter(
        text: TextSpan(text: '$percentage%', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );
    }

    // Dibujar bordes
    final borderPaint =
        Paint()
          ..color =
              prop.isSelected
                  ? (selectedBorderColor ?? Colors.yellow)
                  : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = prop.isSelected ? selectedBorderWidth : 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      prop.startAngle,
      prop.sweepAngle,
      false,
      borderPaint,
    );

    if (prop.isSelected) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: effectiveHoleRadius),
        prop.startAngle,
        prop.sweepAngle,
        false,
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DonutPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.holeRadius != holeRadius ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.progress != progress ||
        oldDelegate.showPercentages != showPercentages ||
        oldDelegate.thickness != thickness ||
        oldDelegate.selectedSegment != selectedSegment ||
        oldDelegate.selectedBorderColor != selectedBorderColor ||
        oldDelegate.selectedBorderWidth != selectedBorderWidth;
  }
}

class _SegmentProperties {
  final PieData segment;
  final double startAngle;
  final double sweepAngle;
  final bool isSelected;

  _SegmentProperties({
    required this.segment,
    required this.startAngle,
    required this.sweepAngle,
    required this.isSelected,
  });
}
