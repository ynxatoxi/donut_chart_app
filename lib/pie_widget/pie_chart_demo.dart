// pie_chart_demo.dart
import 'package:flutter/material.dart';
import 'pie_data_model.dart';
import 'pie_chart_widget.dart';

class PieChartDemo extends StatelessWidget {
  const PieChartDemo({super.key});

  void _showSnackBar(BuildContext context, PieData data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tocado: ${data.title} ${data.value}%'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = PieChartConfig(
      data: [
        PieData(value: 35, color: Colors.blue.shade400, title: 'Trabajo'),
        PieData(value: 25, color: Colors.green.shade400, title: 'Estudio'),
        PieData(value: 20, color: Colors.orange.shade400, title: 'Ocio'),
        PieData(value: 15, color: Colors.red.shade400, title: 'Deporte'),
        PieData(value: 5, color: Colors.purple.shade400, title: 'Otros'),
      ],
      title: 'Distribución de Actividades',
      spaceRadius: 180,
      legendFormat: '%title%::: %value%%',
      legendShape: LegendShape.square,
      legendStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      legendDirection: LegendDirection.vertical,
      percentageTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      onTap: (index) {
        //_showSnackBar(context, data[index].title);
        //_showSnackBar(context, "hola");
        //print('Tocado: ${index}');
      },
      onSegmentTap: (segment) => _showSnackBar(context, segment),
      showLegend: true,
      legendText: (config, data) {
        /*
          if (widget.config.legendFormat != null) {
            return widget.config.legendFormat!(segment);
          }

          // Calculate percentage
          final total = widget.config.data.fold(0.0, (sum, s) => sum + s.value);
          final percentage = (segment.value / total * 100).toStringAsFixed(1);

          return '${segment.title} (${percentage}%)';
         */
        final total = config.data.fold(0.0, (sum, s) => sum + s.value);
        return '$total ${data.title} -- (${data.value}%)';
      },
      optionsBuilder: _buildOptionsCheck,
      //legendBuilder: _buildLegend,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Donut Avanzado'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: PieChartWidget(config: config)),
      ),
    );
  }

  static Widget _buildOptionsSwitch(
    PieChartConfig config,
    bool showLegend,
    ValueChanged<bool> onToggle,
  ) {
    return IntrinsicWidth(
      child: SwitchListTile(
        title: Text(
          'Mostrar leyenda',
          style: (config.legendStyle ?? TextStyle(fontSize: 14)),
        ),
        value: showLegend,
        onChanged: onToggle,
      ),
    );
  }

  static Widget _buildOptionsCheck(
    PieChartConfig config,
    bool showLegend,
    ValueChanged<bool> onToggle,
  ) {
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
            value: showLegend,
            onChanged: (bool? value) {
              onToggle(value ?? false);
            },
          ),
          Text(
            'Legend',
            style: (config.legendStyle ?? const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    PieChartConfig config,
    int? selectedIndex,
    ValueChanged<int?> onSelectionChanged,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children:
          config.data.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final isSelected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                onSelectionChanged(config.data.indexOf(segment));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey.shade200 : null,
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
                            config.legendShape == LegendShape.circle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                        borderRadius:
                            config.legendShape == LegendShape.rectangle
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
                      config.legendText(config, segment),
                      style: (config.legendStyle ??
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
