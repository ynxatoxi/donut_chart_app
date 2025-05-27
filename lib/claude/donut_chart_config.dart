// donut_chart_config.dart
import 'package:flutter/material.dart';

enum LegendShape { circle, square, rectangle, roundedRectangle }

class DonutChartConfig {
  final List<PieData> data;
  final String title;
  final double holeDiameter;
  final String Function(PieData segment)? legendFormat;
  final LegendShape legendShape;
  final TextStyle? titleStyle;
  final TextStyle? legendStyle;
  final TextStyle? segmentLabelStyle;
  final Duration animationDuration;
  final bool showPercentages;
  final bool showLegend;
  final EdgeInsets padding;
  final Color backgroundColor;
  final double thickness;
  final Alignment legendAlignment;
  final double legendSpacing;
  final double chartDiameter;
  final void Function(PieData segment)? onSegmentTap;
  final bool enableSegmentTapping;
  final Color? selectedSegmentBorderColor;
  final double selectedSegmentBorderWidth;

  const DonutChartConfig({
    required this.data,
    this.title = '',
    this.holeDiameter = 100,
    this.legendFormat,
    this.legendShape = LegendShape.circle,
    this.titleStyle,
    this.legendStyle,
    this.segmentLabelStyle,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showPercentages = true,
    this.showLegend = true,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.transparent,
    this.thickness = 40,
    this.legendAlignment = Alignment.center,
    this.legendSpacing = 8.0,
    this.chartDiameter = 300,
    this.onSegmentTap,
    this.enableSegmentTapping = false,
    this.selectedSegmentBorderColor = Colors.yellow,
    this.selectedSegmentBorderWidth = 3.0,
  });
}

class PieData {
  final String title;
  final double value;
  final Color color;
  final dynamic
  extraData; // Para almacenar datos adicionales como IDs, objetos, etc.

  const PieData({
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
