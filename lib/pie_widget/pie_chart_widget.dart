// pie_chart_widget.dart

import 'package:flutter/material.dart';
import 'pie_data_model.dart';
import 'pie_chart.dart';

class PieChartWidget extends StatefulWidget {
  final PieChartConfig config;

  const PieChartWidget({required this.config, super.key});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? _selectedIndex;
  bool _showLegend = true;

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
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            widget.config.optionsBuilder != null
                ? widget.config.optionsBuilder!(
                  widget.config,
                  _showLegend,
                  (value) => setState(() => _showLegend = value),
                )
                : _buildDefaultOption(),
          ],
        ),
        PieChart(
          config: widget.config,
          selectedIndex: _selectedIndex,
          onSelectionChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        const SizedBox(height: 16),
        if (_showLegend && widget.config.showLegend)
          widget.config.legendBuilder?.call(
                widget.config,
                _selectedIndex,
                (index) => setState(() => _selectedIndex = index),
              ) ??
              _buildDefaultLegend(),
      ],
    );
  }

  Widget _buildDefaultOption() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _showLegend,
            onChanged: (bool? value) {
              setState(() {
                _showLegend = value ?? false;
              });
            },
          ),
          Text('Legend'),
        ],
      ),
    );
  }

  Widget _buildDefaultLegend() {
    // Si la dirección es horizontal, usamos Wrap
    if (widget.config.legendDirection == LegendDirection.horizontal) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: _buildLegendItems(),
      );
    } else {
      // Si la dirección es vertical, usamos Column
      return Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: _buildLegendItems(),
      );
    }
  }

  List<Widget> _buildLegendItems() {
    return widget.config.data.asMap().entries.map((entry) {
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
            color: isSelected ? Colors.grey.shade200 : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize:
                widget.config.legendDirection == LegendDirection.horizontal
                    ? MainAxisSize
                        .min // Para horizontal, ocupar el mínimo espacio
                    : MainAxisSize
                        .max, // Para vertical, ocupar el máximo espacio
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
              Flexible(
                child: Text(
                  widget.config.legendText(widget.config, segment),
                  style: (widget.config.legendStyle ??
                          const TextStyle(fontSize: 14))
                      .copyWith(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                  overflow:
                      TextOverflow
                          .ellipsis, // Maneja el desbordamiento de texto
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
