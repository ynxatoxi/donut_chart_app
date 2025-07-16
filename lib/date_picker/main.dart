import 'package:flutter/material.dart';
import './generic_example.dart';
// Asegúrate de que esta ruta sea correcta para tu proyecto

// Importa las clases de ejemplo que proporcionaste
//import 'package:xatopay/date_examples.dart'; // Asume que guardaste tu código en date_picker_examples.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Date Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplos de Date Pickers')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatePickerExamples(),
                  ),
                );
              },
              child: const Text('Ver Ejemplos de Date Pickers'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DatePickerUsageExample(),
                  ),
                );
              },
              child: const Text('Ver Ejemplo de Uso Práctico'),
            ),
          ],
        ),
      ),
    );
  }
}
