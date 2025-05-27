import 'package:flutter/material.dart';
import 'phone_widget.dart';

// Widget de ejemplo para mostrar cómo usar el InternationalPhoneWidget
class PhoneWidgetExample extends StatefulWidget {
  const PhoneWidgetExample({super.key});

  @override
  _PhoneWidgetExampleState createState() => _PhoneWidgetExampleState();
}

class _PhoneWidgetExampleState extends State<PhoneWidgetExample> {
  String _phoneNumber = '';
  CountryData? _selectedCountry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text('Selector de Teléfono Internacional'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingresa tu número de teléfono:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            PhoneWidget(
              onPhoneChanged: (phone) {
                setState(() {
                  _phoneNumber = phone;
                });
              },
              onCountryChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                });
              },
              decoration: InputDecoration(
                hintText: 'Ej: 123456789',
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información actual:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_selectedCountry != null) ...[
                    Text(
                      'País: ${_selectedCountry!.flag} ${_selectedCountry!.name}',
                    ),
                    Text('Código: ${_selectedCountry!.dialCode}'),
                  ],
                  Text('Teléfono: $_phoneNumber'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Funciones inteligentes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Escribe "+58" y el selector cambiará automáticamente a Venezuela\n'
                    '• Escribe "+34" para España, "+1" para EE.UU., etc.\n'
                    '• Click en la bandera para ver todos los países disponibles',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
