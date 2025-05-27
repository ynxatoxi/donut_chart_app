import 'package:flutter/material.dart';
import 'dart:math';

// Importar el archivo que contiene nuestro widget de gráfico dona
import 'donut_chart.dart';

void main() {
  //runApp(const DonutChartApp());
  runApp(const MyApp());
}

class DonutChartApp extends StatelessWidget {
  const DonutChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico de Dona',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DonutChartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DonutChartScreen extends StatelessWidget {
  const DonutChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos para el gráfico
    final segments = [
      DonutSegment(value: 35, color: Colors.blue.shade400, label: 'Trabajo'),
      DonutSegment(value: 25, color: Colors.green.shade400, label: 'Estudio'),
      DonutSegment(value: 20, color: Colors.orange.shade400, label: 'Ocio'),
      DonutSegment(value: 15, color: Colors.red.shade400, label: 'Deporte'),
      DonutSegment(value: 5, color: Colors.purple.shade400, label: 'Otros'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Gráfico de Dona'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Distribución de actividades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: DonutChart(
                  segments: segments,
                  diameter: min(MediaQuery.of(context).size.width,
                          MediaQuery.of(context).size.height) -
                      100,
                  holeDiameter: 100,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegend(segments),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(List<DonutSegment> segments) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: segments.map((segment) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: segment.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${segment.label} (${segment.value}%)',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class DonutSegment {
  final double value;
  final Color color;
  final String label;

  DonutSegment({
    required this.value,
    required this.color,
    required this.label,
  });
}

class DonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double diameter;
  final double holeDiameter;
  final TextStyle textStyle;

  const DonutChart({
    required this.segments,
    required this.diameter,
    required this.holeDiameter,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: DonutPainter(
        segments: segments,
        holeRadius: holeDiameter / 2,
        textStyle: textStyle,
      ),
    );
  }
}

class DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double holeRadius;
  final TextStyle textStyle;

  DonutPainter({
    required this.segments,
    required this.holeRadius,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = segments.fold(0.0, (sum, segment) => sum + segment.value);
    final radius = size.width / 2;

    // Dibujar los segmentos
    double startAngle = -pi / 2; // Comenzar desde la parte superior

    for (var segment in segments) {
      final sweepAngle = 2 * pi * (segment.value / total);
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;

      // Dibujar el segmento de la dona
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..lineTo(center.dx, center.dy)
        ..close();

      final holePath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: holeRadius));
      
      final donutPath = Path.combine(
        PathOperation.difference,
        path,
        holePath,
      );

      canvas.drawPath(donutPath, paint);

      // Calcular posición para el texto
      final middleAngle = startAngle + sweepAngle / 2;
      final textRadius = (radius + holeRadius) / 2;
      final textX = center.dx + textRadius * cos(middleAngle);
      final textY = center.dy + textRadius * sin(middleAngle);

      // Dibujar el porcentaje
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(segment.value / total * 100).toStringAsFixed(1)}%',
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
      );

      // Dibujar bordes
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        borderPaint,
      );

      startAngle += sweepAngle;
    }

    // Borde interior
    final innerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, holeRadius, innerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gráfico Donut Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DonutChartExample(),
    );
  }
}

class DonutChartExample extends StatelessWidget {
  const DonutChartExample({super.key}) ;

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para nuestro gráfico
    final chartData = [
      DonutChartData(
        label: 'Flutter',
        value: 40,
        color: Colors.blue,
      ),
      DonutChartData(
        label: 'React Native',
        value: 25,
        color: Colors.green,
      ),
      DonutChartData(
        label: 'Native Android',
        value: 20,
        color: Colors.red,
      ),
      DonutChartData(
        label: 'Native iOS',
        value: 15,
        color: Colors.orange,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico Donut Personalizado'),
      ),
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
              child: DonutChart2(
                data: chartData,
                strokeWidth: 20,
                innerRadiusRatio: 0.5,
                showPercentageLabels: true,
                percentageTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Leyenda del gráfico
            Column(
              children: chartData.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        color: item.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${item.label} (${item.value}%)",
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