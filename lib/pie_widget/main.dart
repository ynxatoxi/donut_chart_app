// main.dart
import 'package:flutter/material.dart';
// Importar el archivo que contiene nuestro widget de gráfico dona
import 'pie_chart_demo.dart';

void main() {
  //runApp(const DonutChartApp());
  runApp(const MainChartApp());
}

class MainChartApp extends StatelessWidget {
  const MainChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico de XATOXI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PieChartDemo(),
      debugShowCheckedModeBanner: true,
    );
  }
}
