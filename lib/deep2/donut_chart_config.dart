// donut_chart_config.dart
import 'package:flutter/material.dart';

class PieData {
  final String title;
  final double value;
  final Color color;
  final dynamic
  extraData; // Para almacenar datos adicionales como IDs, objetos, etc.

  PieData({
    required this.title,
    required this.value,
    required this.color,
    this.extraData,
  });

  // Método de fábrica para crear un PieData desde un mapa (para JSON)
  factory PieData.fromJson(Map<String, dynamic> json, {Color? defaultColor}) {
    return PieData(
      title: json['title'] ?? '',
      value: (json['value'] is num) ? (json['value'] as num).toDouble() : 0.0,
      color:
          json['color'] != null
              ? Color(int.parse(json['color'], radix: 16) + 0xFF000000)
              : defaultColor ?? Colors.grey,
      extraData: json['extraData'],
    );
  }
}

enum LegendShape { circle, square, rectangle }

class DonutChartConfig {
  final List<PieData> data;
  final String? title;
  final double spaceRadius;
  final String legendFormat;
  final LegendShape legendShape;
  final TextStyle? legendStyle;
  final TextStyle? titleStyle;
  final Function(int)? onTap;
  final void Function(PieData segment)? onSegmentTap;
  final Duration animationDuration;
  final double strokeWidth;
  final Color strokeColor;

  final String Function(PieData) legendText;
  final bool showPercentages;
  final bool showLegend;
  final int? selectedIndex; // Índice del segmento seleccionado

  DonutChartConfig({
    required this.data,
    this.title,
    this.spaceRadius = 180,
    this.legendFormat = '%title% (%value%%)',
    this.legendShape = LegendShape.circle,
    this.legendStyle,
    this.titleStyle,
    this.onTap,
    this.onSegmentTap,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.strokeWidth = 2,
    this.strokeColor = Colors.white,
    this.legendText = _defaultFormatter,
    this.showPercentages = true,
    this.showLegend = true,
    this.selectedIndex,
  }) : assert(data.isNotEmpty, 'Data list cannot be empty'),
       assert(spaceRadius > 0, 'Hole diameter must be greater than 0'),
       assert(strokeWidth > 0, 'Stroke width must be greater than 0'),
       assert(legendFormat.isNotEmpty, 'Legend format cannot be empty');

  String getFormattedLegend(PieData segment) {
    return legendFormat
        .replaceAll('%title%', segment.title)
        .replaceAll('%value%', segment.value.toStringAsFixed(1));
  }

  static String _defaultFormatter(PieData segment) {
    return '${segment.title} (${segment.value}%)';
  }
}
