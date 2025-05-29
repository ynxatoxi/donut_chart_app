// widget.dart

import 'package:flutter/material.dart';
import 'pie_data.dart';
import 'pie_widget.dart';

class DonutChart extends StatefulWidget {
  final DonutChartConfig config;

  const DonutChart({required this.config, super.key});

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.config.title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              widget.config.title!,
              style:
                  widget.config.titleStyle ??
                  Theme.of(context).textTheme.titleLarge,
            ),
          ),
        InteractiveDonutChart(
          config: widget.config,
          selectedIndex: _selectedIndex,
          onSelectionChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        const SizedBox(height: 16),
        if (widget.config.showLegend) _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children:
          widget.config.data.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isSelected = index == _selectedIndex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = _selectedIndex == index ? null : index;
                });
                widget.config.onSegmentTap?.call(segment);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.withOpacity(0.2) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: segment.color,
                        shape:
                            widget.config.legendShape == LegendShape.circle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                        borderRadius:
                            widget.config.legendShape == LegendShape.rectangle
                                ? BorderRadius.circular(4)
                                : null,
                        border:
                            isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.config.legendText(segment),
                      style: (widget.config.legendStyle ??
                              const TextStyle(fontSize: 14))
                          .copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
