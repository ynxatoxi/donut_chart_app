// api_service.dart - Clase para manejar peticiones a la API
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'donut_chart_config.dart';
import 'package:flutter/material.dart';

class ChartDataApiService {
  final String apiBaseUrl;

  ChartDataApiService({required this.apiBaseUrl});

  Future<List<PieData>> fetchChartData() async {
    try {
      final response = await http
          .get(Uri.parse('$apiBaseUrl/chart-data'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return _parseChartData(jsonData);
      } else {
        throw Exception('Error en la API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  Future<bool> updateChartData(List<PieData> data) async {
    // Implementar lógica para enviar datos actualizados a la API
    // (depende de cómo esté estructurada tu API)
    return true;
  }

  List<PieData> _parseChartData(Map<String, dynamic> jsonData) {
    final List<dynamic> items = jsonData['data'];
    final List<PieData> pieData = [];

    final fallbackColors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.purple.shade400,
    ];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final fallbackColor =
          i < fallbackColors.length
              ? fallbackColors[i]
              : fallbackColors[i % fallbackColors.length];

      pieData.add(PieData.fromJson(item, defaultColor: fallbackColor));
    }

    return pieData;
  }
}
