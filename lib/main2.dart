import 'package:flutter/material.dart';

// Importar el archivo que contiene nuestro widget de gráfico dona
import 'claude_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico Donut Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const DonutChartExample(),
    );
  }
}

class DonutChartExample extends StatelessWidget {
  const DonutChartExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para nuestro gráfico usando la estructura PieData
    final chartData = [
      PieData(title: 'Flutter', percent: 40, color: Colors.blue),
      PieData(title: 'React Native', percent: 25, color: Colors.green),
      PieData(title: 'Native Android', percent: 20, color: Colors.red),
      PieData(title: 'Native iOS', percent: 15, color: Colors.orange),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Gráfico Donut Personalizado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Gráfico tipo dona con porcentajes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Contenedor para el gráfico
            SizedBox(
              height: 300,
              width: 300,
              child: DonutChart(
                data: chartData,
                strokeWidth: 60,
                innerRadiusRatio: 0.6, // Controla el tamaño del hueco central
                showPercentageLabels: true,
              ),
            ),
            const SizedBox(height: 40),
            // Leyenda del gráfico
            Column(
              children:
                  chartData.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 20, height: 20, color: item.color),
                          const SizedBox(width: 8),
                          Text(
                            "${item.title} (${item.percent}%)",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
