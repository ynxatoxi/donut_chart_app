import 'package:flutter/material.dart';
import './generic_date_picker.dart';

class DatePickerExamples extends StatefulWidget {
  const DatePickerExamples({super.key});

  @override
  State<DatePickerExamples> createState() => _DatePickerExamplesState();
}

class _DatePickerExamplesState extends State<DatePickerExamples> {
  DateTime? selectedSingleDate;
  DateTime? selectedInitialDate;
  DateTime? selectedFinalDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Date Picker Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ejemplo 1: Fecha individual
            const Text(
              '1. Fecha Individual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.single,
              singleDateLabel: 'Seleccionar fecha',
              borderColor: Colors.blue,
              onDateSelected: (date) {
                setState(() {
                  selectedSingleDate = date;
                });
                print('Fecha seleccionada: ${date.toString()}');
              },
            ),
            if (selectedSingleDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Fecha seleccionada: ${_formatDate(selectedSingleDate!)}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            const SizedBox(height: 24),

            // Ejemplo 2: Rango de fechas horizontal
            const Text(
              '2. Rango de Fechas (Horizontal)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.range,
              layout: DatePickerLayout.horizontal,
              initialDateLabel: 'Fecha inicial',
              finalDateLabel: 'Fecha final',
              borderColor: Colors.blue,
              onDateRangeSelected: (initial, final1) {
                setState(() {
                  selectedInitialDate = initial;
                  selectedFinalDate = final1;
                });
                print(
                  'Rango seleccionado: ${initial.toString()} - ${final1.toString()}',
                );
              },
            ),
            if (selectedInitialDate != null && selectedFinalDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Rango: ${_formatDate(selectedInitialDate!)} - ${_formatDate(selectedFinalDate!)}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),

            const SizedBox(height: 24),

            // Ejemplo 3: Rango de fechas vertical
            const Text(
              '3. Rango de Fechas (Vertical)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.range,
              layout: DatePickerLayout.vertical,
              initialDateLabel: 'Fecha de inicio',
              finalDateLabel: 'Fecha de fin',
              borderColor: Colors.purple,
              width: double.infinity,
              onDateRangeSelected: (initial, final1) {
                print(
                  'Rango vertical: ${initial.toString()} - ${final1.toString()}',
                );
              },
            ),

            const SizedBox(height: 24),

            // Ejemplo 4: Personalizado con diferentes colores
            const Text(
              '4. Personalizado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.single,
              singleDateLabel: 'Fecha personalizada',
              borderColor: Colors.red,
              backgroundColor: Colors.red.shade50,
              textColor: Colors.red.shade700,
              iconColor: Colors.red,
              borderRadius: 12,
              height: 60,
              dateFormat: 'yyyy-MM-dd',
              onDateSelected: (date) {
                print('Fecha personalizada: ${date.toString()}');
              },
            ),

            const SizedBox(height: 24),

            // Ejemplo 5: Solo lectura
            const Text(
              '5. Solo Lectura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.single,
              initialDate: DateTime.now(),
              readOnly: true,
              singleDateLabel: 'Fecha bloqueada',
              borderColor: Colors.grey,
              textColor: Colors.grey,
              iconColor: Colors.grey,
            ),

            const SizedBox(height: 24),

            // Ejemplo 6: Con límites de fecha
            const Text(
              '6. Con Límites de Fecha',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GenericDatePicker(
              mode: DatePickerStyle.range,
              layout: DatePickerLayout.horizontal,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
              borderColor: Colors.orange,
              onDateRangeSelected: (initial, final1) {
                print(
                  'Rango limitado: ${initial.toString()} - ${final1.toString()}',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// Ejemplo de uso en una clase que necesita las fechas como texto
class DatePickerUsageExample extends StatefulWidget {
  const DatePickerUsageExample({super.key});

  @override
  State<DatePickerUsageExample> createState() => _DatePickerUsageExampleState();
}

class _DatePickerUsageExampleState extends State<DatePickerUsageExample> {
  String initialDateText = '';
  String finalDateText = '';
  String singleDateText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uso Práctico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Para obtener fecha individual como texto
            GenericDatePicker(
              mode: DatePickerStyle.single,
              dateFormat: 'yyyy-MM-dd', // Formato para base de datos
              onDateSelected: (date) {
                setState(() {
                  singleDateText = _formatDateForAPI(date);
                });
              },
            ),

            const SizedBox(height: 16),

            // Para obtener rango como texto
            GenericDatePicker(
              mode: DatePickerStyle.range,
              onDateRangeSelected: (initial, final1) {
                setState(() {
                  initialDateText = _formatDateForAPI(initial);
                  finalDateText = _formatDateForAPI(final1);
                });
              },
            ),

            const SizedBox(height: 24),

            // Mostrar los resultados
            if (singleDateText.isNotEmpty)
              Text('Fecha individual: $singleDateText'),
            if (initialDateText.isNotEmpty && finalDateText.isNotEmpty)
              Text('Rango: $initialDateText a $finalDateText'),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // Simular envío a API
                _sendToAPI();
              },
              child: const Text('Enviar a API'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _sendToAPI() {
    // Ejemplo de cómo enviar las fechas como texto a una API
    Map<String, dynamic> data = {};

    if (singleDateText.isNotEmpty) {
      data['selected_date'] = singleDateText;
    }

    if (initialDateText.isNotEmpty && finalDateText.isNotEmpty) {
      data['start_date'] = initialDateText;
      data['end_date'] = finalDateText;
    }

    print('Datos a enviar: $data');
    // Aquí harías tu llamada a la API
  }
}
