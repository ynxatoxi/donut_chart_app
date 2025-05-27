// main.dart - Ejemplo de uso con Provider para gestión de estado
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'donut_chart_config.dart';
import 'custom_donut_chart.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donut Chart Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: ChangeNotifierProvider(
        create:
            (_) => ChartDataProvider(
              apiService: ChartDataApiService(
                apiBaseUrl: 'https://api.example.com',
              ),
            ),
        child: const ChartDashboardScreen(),
      ),
    );
  }
}

class ChartDataProvider extends ChangeNotifier {
  final ChartDataApiService apiService;

  bool isLoading = false;
  String errorMessage = '';
  List<PieData> chartData = [];
  PieData? selectedSegment;

  ChartDataProvider({required this.apiService}) {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading = true;
      errorMessage = '';
      notifyListeners();

      // Para pruebas, usamos datos simulados en lugar de la API real
      await Future.delayed(const Duration(seconds: 1));

      // Datos simulados - en un escenario real, usar:
      // chartData = await apiService.fetchChartData();
      chartData = [
        PieData(
          title: 'Trabajo..',
          value: 35,
          color: Colors.blue.shade400,
          extraData: {
            'id': 'work_1',
            'description': 'Tiempo dedicado al trabajo',
          },
        ),
        PieData(
          title: 'Estudio',
          value: 25,
          color: Colors.green.shade400,
          extraData: {
            'id': 'study_1',
            'description': 'Tiempo dedicado al estudio',
          },
        ),
        PieData(
          title: 'Ocio',
          value: 20,
          color: Colors.orange.shade400,
          extraData: {
            'id': 'leisure_1',
            'description': 'Tiempo dedicado al ocio',
          },
        ),
        PieData(
          title: 'Deporte',
          value: 15,
          color: Colors.red.shade400,
          extraData: {
            'id': 'sport_1',
            'description': 'Tiempo dedicado al deporte',
          },
        ),
        PieData(
          title: 'Otros',
          value: 5,
          color: Colors.purple.shade400,
          extraData: {
            'id': 'other_1',
            'description': 'Tiempo dedicado a otras actividades',
          },
        ),
      ];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void selectSegment(PieData? segment) {
    selectedSegment = (selectedSegment == segment) ? null : segment;
    notifyListeners();
  }
}

class ChartDashboardScreen extends StatelessWidget {
  const ChartDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard con Gráfico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                () =>
                    Provider.of<ChartDataProvider>(
                      context,
                      listen: false,
                    ).fetchData(),
          ),
        ],
      ),
      body: Consumer<ChartDataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: provider.fetchData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.chartData.isEmpty) {
            return const Center(child: Text('No hay datos disponibles'));
          }

          return Column(
            children: [
              Expanded(
                child: CustomDonutChart(
                  config: DonutChartConfig(
                    data: provider.chartData,
                    title: 'Distribución de Actividades',
                    holeDiameter: 150,
                    enableSegmentTapping: true,
                    onSegmentTap: provider.selectSegment,
                    selectedSegmentBorderColor: Colors.amber,
                  ),
                ),
              ),
              if (provider.selectedSegment != null)
                _buildSelectedSegmentDetails(provider.selectedSegment!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedSegmentDetails(PieData segment) {
    final extraData = segment.extraData;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: segment.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: segment.color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            segment.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: segment.color,
            ),
          ),
          const SizedBox(height: 8),
          Text('Valor: ${segment.value}'),
          if (extraData != null && extraData is Map<String, dynamic>)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(extraData['description'] ?? ''),
            ),
        ],
      ),
    );
  }
}
