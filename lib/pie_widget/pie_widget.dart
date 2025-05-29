// interactive_donut_chart.dart
import 'package:flutter/material.dart';
import 'pie_data.dart';
import 'pie_painter.dart';

class InteractiveDonutChart extends StatefulWidget {
  final DonutChartConfig config;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectionChanged;

  const InteractiveDonutChart({
    required this.config,
    this.selectedIndex,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<InteractiveDonutChart> createState() => _InteractiveDonutChartState();
}

class _InteractiveDonutChartState extends State<InteractiveDonutChart> {
  DonutPainter? _painter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: widget.config.animationDuration,
      curve: Curves.easeInOut,
      builder: (context, progress, child) {
        _painter = DonutPainter(
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
              final newSelection =
                  touchedSegment == widget.selectedIndex
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
