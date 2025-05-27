import 'package:flutter/material.dart';
import 'phone_widget2.dart';

class PhoneWidgetExample extends StatefulWidget {
  const PhoneWidgetExample({super.key});

  @override
  State<PhoneWidgetExample> createState() => _PhoneWidgetExampleState();
}

class _PhoneWidgetExampleState extends State<PhoneWidgetExample> {
  String _phoneNumber = '';
  CountryData? _selectedCountry;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: const Text('Selector de Teléfono Internacional'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 12),
              PhoneWidget(
                initialCountryCode: 'VE', // País inicial
                onPhoneChanged: (completePhone) {
                  setState(() {
                    _phoneNumber = completePhone;
                  });
                },
                onCountryChanged: (country) {
                  setState(() {
                    _selectedCountry = country;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Ej: 4121234567',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textStyle: const TextStyle(fontSize: 16),
                dropdownTextStyle: const TextStyle(fontSize: 14),
                dropdownDialCodeStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade800,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un número de teléfono';
                  }
                  if (value.length < 8) {
                    return 'El número debe tener al menos 8 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 8),
                    if (_selectedCountry != null) ...[
                      Text(
                        'País: ${_selectedCountry!.flag} ${_selectedCountry!.name}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Código: ${_selectedCountry!.dialCode}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    Text(
                      'Número completo: $_phoneNumber',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(height: 8),
                    Text(
                      '• Escribe "+58" y el selector cambiará automáticamente a Venezuela\n'
                      '• Escribe "+34" para España, "+1" para EE.UU., etc.\n'
                      '• Click en la bandera para ver todos los países disponibles\n'
                      '• Validación automática del número de teléfono',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Número registrado'),
                              content: Text(
                                'Número completo: $_phoneNumber\n'
                                'País: ${_selectedCountry?.name ?? 'No seleccionado'}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                  child: const Text('Validar y Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
