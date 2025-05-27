// example_usage.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'donut_chart_config.dart';
import 'custom_donut_chart.dart';

class DonutChartExample extends StatefulWidget {
  const DonutChartExample({super.key});

  @override
  State<DonutChartExample> createState() => _DonutChartExampleState();
}

class _DonutChartExampleState extends State<DonutChartExample> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<PieData> _chartData = [];
  PieData? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _fetchChartData();
  }

  Future<void> _fetchChartData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // En un escenario real, reemplaza esto con tu URL de API
      // final response = await http.get(Uri.parse('https://api.example.com/chart-data'));

      // Para este ejemplo, simulamos una respuesta de API con datos estáticos
      // (ya que la URL de ejemplo no es real)
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simular el tiempo de carga
      const fakeJsonResponse = '''
      {
        "status": "success",
        "data": [
          {"title": "Trabajo", "value": 35, "color": "4285F4", "extraData": {"id": "work_1", "description": "Tiempo dedicado al trabajo"}},
          {"title": "Estudio", "value": 25, "color": "34A853", "extraData": {"id": "study_1", "description": "Tiempo dedicado al estudio"}},
          {"title": "Ocio", "value": 20, "color": "FBBC05", "extraData": {"id": "leisure_1", "description": "Tiempo dedicado al ocio"}},
          {"title": "Deporte", "value": 15, "color": "EA4335", "extraData": {"id": "sport_1", "description": "Tiempo dedicado al deporte"}},
          {"title": "Otros", "value": 5, "color": "9C27B0", "extraData": {"id": "other_1", "description": "Tiempo dedicado a otras actividades"}}
        ]
      }
      ''';

      final jsonData = json.decode(fakeJsonResponse);

      if (jsonData['status'] == 'success') {
        final List<dynamic> items = jsonData['data'];
        final List<PieData> pieData = [];

        // Lista de colores alternativos por si el JSON no proporciona colores
        final fallbackColors = [
          Colors.blue.shade400,
          Colors.green.shade400,
          Colors.orange.shade400,
          Colors.red.shade400,
          Colors.purple.shade400,
          Colors.teal.shade400,
          Colors.amber.shade400,
          Colors.pink.shade400,
        ];

        // Convertir los datos JSON a objetos PieData
        for (int i = 0; i < items.length; i++) {
          final item = items[i];
          final fallbackColor =
              i < fallbackColors.length
                  ? fallbackColors[i]
                  : fallbackColors[i % fallbackColors.length];

          pieData.add(PieData.fromJson(item, defaultColor: fallbackColor));
        }

        setState(() {
          _chartData = pieData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error en la respuesta de la API';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleSegmentTap(PieData segment) {
    setState(() {
      _selectedSegment = segment == _selectedSegment ? null : segment;
    });

    // Mostrar detalles del segmento seleccionado
    if (segment != _selectedSegment) {
      _showSegmentDetails(segment);
    }
  }

  void _showSegmentDetails(PieData segment) {
    final extraData = segment.extraData;
    String detailsText = 'Detalles no disponibles';

    if (extraData != null && extraData is Map<String, dynamic>) {
      detailsText = extraData['description'] ?? 'Sin descripción';
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(segment.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: segment.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Valor: ${segment.value}'),
                const SizedBox(height: 8),
                Text(detailsText),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico con Datos Dinámicos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchChartData,
            tooltip: 'Recargar datos',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchChartData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_chartData.isEmpty) {
      return const Center(child: Text('No hay datos disponibles para mostrar'));
    }

    // Configuración personalizada con los datos cargados
    final config = DonutChartConfig(
      data: _chartData,
      title: 'Distribución de Actividades',
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
      enableSegmentTapping: true, // Activar detección de toques
      onSegmentTap: _handleSegmentTap, // Callback para manejar los toques
      selectedSegmentBorderColor: Colors.amber,
      selectedSegmentBorderWidth: 3.0,
    );

    return CustomDonutChart(config: config);
  }
}
