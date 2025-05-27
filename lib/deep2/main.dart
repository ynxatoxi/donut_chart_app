import 'package:flutter/material.dart';


// Importar el archivo que contiene nuestro widget de gráfico dona
import 'deek_seek_screen.dart';

void main() {
  //runApp(const DonutChartApp());
  runApp(const DonutChartApp());
}

class DonutChartApp extends StatelessWidget {
  const DonutChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico de DeekSeek',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DonutChartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}