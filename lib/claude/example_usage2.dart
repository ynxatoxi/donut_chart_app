// example_usage2.dart
import 'package:flutter/material.dart';
import 'donut_chart_config.dart';
import 'custom_donut_chart.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donut Chart Demo 2',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: DonutChartExample(),
    );
  }
}

class DonutChartExample extends StatelessWidget {
  const DonutChartExample({super.key});

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

    // Configuración personalizada
    final config = DonutChartConfig(
      data: segments,
      title: 'Distribución de Actividades 2',
      holeDiameter: 150,
      chartDiameter: 300,
      legendShape: LegendShape.circle,
      titleStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
      legendStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      segmentLabelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      animationDuration: const Duration(milliseconds: 1500),
      showPercentages: true,
      legendFormat: (segment) {
        final total = segments.fold(0.0, (sum, s) => sum + s.value);
        final percentage = (segment.value / total * 100).toStringAsFixed(1);
        return '${segment.title} ($percentage%)';
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Personalizado'),
        centerTitle: true,
      ),
      body: CustomDonutChart(config: config),
    );
  }
}
