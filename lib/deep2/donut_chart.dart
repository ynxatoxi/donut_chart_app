// donut_chart.dart
import 'package:flutter/material.dart';
import 'donut_chart_config.dart';
import 'deekseek_animate_chart.dart';

class DonutChart extends StatelessWidget {
  final DonutChartConfig config;

  const DonutChart({required this.config, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (config.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              config.title!,
              style:
                  config.titleStyle ?? Theme.of(context).textTheme.titleLarge,
            ),
          ),
        InteractiveDonutChart(config: config),
        const SizedBox(height: 16),
        if (config.showLegend) _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children:
          config.data.map((segment) {
            return GestureDetector(
              onTap: () {
                //final index = config.data.indexOf(segment);
                if (config.onSegmentTap != null) config.onSegmentTap!(segment);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: segment.color,
                      shape:
                          config.legendShape == LegendShape.circle
                              ? BoxShape.circle
                              : config.legendShape == LegendShape.square
                              ? BoxShape.rectangle
                              : BoxShape.rectangle,
                      borderRadius:
                          config.legendShape == LegendShape.rectangle
                              ? BorderRadius.circular(4)
                              : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    //config.getFormattedLegend(segment),
                    config.legendText(segment),
                    style: config.legendStyle ?? const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
