// deek_seek_screen.dart
import 'package:flutter/material.dart';
import 'pie_data.dart';
import 'widget.dart';

class DonutChartScreen extends StatelessWidget {
  const DonutChartScreen({super.key});

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
    final config = DonutChartConfig(
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
      onTap: (index) {
        //_showSnackBar(context, data[index].title);
        //_showSnackBar(context, "hola");
        //print('Tocado: ${index}');
      },
      onSegmentTap: (segment) => _showSnackBar(context, segment),
      showLegend: true,
      legendText: (data) {
        /*
          if (widget.config.legendFormat != null) {
            return widget.config.legendFormat!(segment);
          }

          // Calculate percentage
          final total = widget.config.data.fold(0.0, (sum, s) => sum + s.value);
          final percentage = (segment.value / total * 100).toStringAsFixed(1);

          return '${segment.title} (${percentage}%)';
         */

        return '${data.title} -- (${data.value}%)';
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Donut Avanzado'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: DonutChart(config: config)),
      ),
    );
  }
}
