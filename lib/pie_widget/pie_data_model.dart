// pie_data_model.dart
import 'package:flutter/material.dart';

class PieData {
  final String title;
  final double value;
  final Color color;
  final dynamic extraData;

  PieData({
    required this.title,
    required this.value,
    required this.color,
    this.extraData,
  });

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

enum LegendDirection { horizontal, vertical }

class PieChartConfig {
  final List<PieData> data;
  final String? title;
  final double spaceRadius;
  final String legendFormat;
  final LegendShape legendShape;
  final TextStyle? legendStyle;
  final TextStyle? titleStyle;
  final TextStyle percentageTextStyle;
  final Function(int)? onTap;
  final void Function(PieData segment)? onSegmentTap;
  final Duration animationDuration;
  final double strokeWidth;
  final Color strokeColor;
  final String Function(PieChartConfig, PieData) legendText;
  final bool showPercentages;
  final bool showLegend;
  final double
  selectedOffset; // Distancia de separación del segmento seleccionado
  final LegendDirection legendDirection;

  final Widget Function(
    PieChartConfig config,
    bool showLegend,
    ValueChanged<bool> onToggle,
  )?
  optionsBuilder;

  final Widget Function(
    PieChartConfig config,
    int? selectedIndex,
    ValueChanged<int?> onSelectionChanged,
  )?
  legendBuilder;

  PieChartConfig({
    required this.data,
    this.title,
    this.spaceRadius = 180,
    this.legendFormat = '%title% (%value%%)',
    this.legendShape = LegendShape.circle,
    this.legendStyle,
    this.titleStyle,
    this.percentageTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.onTap,
    this.onSegmentTap,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.strokeWidth = 2,
    this.strokeColor = Colors.white,
    this.legendText = _defaultFormatter,
    this.showPercentages = true,
    this.showLegend = true,
    this.selectedOffset = 15.0, // Añadido: offset para segmento seleccionado
    this.legendDirection = LegendDirection.horizontal,
    this.optionsBuilder, // = defaultLegendVisibilityBuilder,
    this.legendBuilder,
  }) : assert(data.isNotEmpty, 'Data list cannot be empty'),
       assert(spaceRadius > 0, 'Hole diameter must be greater than 0'),
       assert(strokeWidth > 0, 'Stroke width must be greater than 0'),
       assert(legendFormat.isNotEmpty, 'Legend format cannot be empty');

  String getFormattedLegend(PieData segment) {
    return legendFormat
        .replaceAll('%title%', segment.title)
        .replaceAll('%value%', segment.value.toStringAsFixed(1));
  }

  static String _defaultFormatter(PieChartConfig config, PieData segment) {
    return '${segment.title} (${segment.value}%)';
  }

  static Widget defaultLegendVisibilityBuilder(
    bool showLegend,
    ValueChanged<bool> onToggle,
  ) {
    return IntrinsicWidth(
      child: SwitchListTile(
        title: const Text('Legend'),
        value: showLegend,
        onChanged: onToggle,
      ),
    );
  }
}
