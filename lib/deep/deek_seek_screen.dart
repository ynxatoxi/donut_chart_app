import 'package:flutter/material.dart';
import 'dart:math';
import 'deekseek_animate_chart.dart';

//import 'deekseek_donut_chart.dart';
class DonutChartScreen extends StatelessWidget {
  const DonutChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos para el gráfico
    final segments = [
      PieData(value: 35, color: Colors.blue.shade400, title: 'Trabajo'),
      PieData(value: 25, color: Colors.green.shade400, title: 'Estudio'),
      PieData(value: 20, color: Colors.orange.shade400, title: 'Ocio'),
      PieData(value: 15, color: Colors.red.shade400, title: 'Deporte'),
      PieData(value: 5, color: Colors.purple.shade400, title: 'Otros'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribución de Actividades'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Distribución de actividades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: InteractiveDonutChart(
                  segments: segments,
                  diameter:
                      min(
                        MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height,
                      ) -
                      100,
                  holeDiameter: 180,
                  duration: const Duration(milliseconds: 1500),
                  onSegmentTapped: (index) {
                    // Muestra un snackbar con la información del segmento
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Segmento seleccionado: ${segments[index].title} (${segments[index].value}%)',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(segments),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<PieData> segments) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children:
          segments.map((segment) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: segment.color,
                    shape: BoxShape.rectangle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${segment.title} (${segment.value}%)',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }).toList(),
    );
  }
}
