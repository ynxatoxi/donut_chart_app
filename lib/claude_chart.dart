import 'dart:math';
import 'package:flutter/material.dart';

class PieData {
  final String title;
  final double percent;
  final Color color;

  const PieData({
    required this.title,
    required this.percent,
    required this.color,
  });
}

class DonutChart extends StatelessWidget {
  final List<PieData> data;
  final double strokeWidth;
  final double innerRadiusRatio;
  final bool showPercentageLabels;
  final TextStyle? percentageTextStyle;

  const DonutChart({
    super.key,
    required this.data,
    this.strokeWidth = 30.0,
    this.innerRadiusRatio =
        0.6, // Relación entre radio interno y externo (controla tamaño del hueco)
    this.showPercentageLabels = true,
    this.percentageTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Usar directamente el porcentaje desde la clase PieData
    // No necesitamos calcular un total

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          size: size,
          painter: DonutChartPainter(
            data: data,
            total:
                100.0, // Asumimos que los porcentajes ya están calculados (suman 100)
            strokeWidth: strokeWidth,
            innerRadiusRatio: innerRadiusRatio,
            showPercentageLabels: showPercentageLabels,
            percentageTextStyle:
                percentageTextStyle ??
                TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: strokeWidth * 0.4,
                ),
          ),
        );
      },
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<PieData> data;
  final double total;
  final double strokeWidth;
  final double innerRadiusRatio;
  final bool showPercentageLabels;
  final TextStyle percentageTextStyle;

  DonutChartPainter({
    required this.data,
    required this.total,
    required this.strokeWidth,
    required this.innerRadiusRatio,
    required this.showPercentageLabels,
    required this.percentageTextStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - (strokeWidth / 2);

    // Calcular radio interno (para crear el efecto "dona")
    final innerRadius = radius * innerRadiusRatio;
    final outerRadius = radius;

    double startAngle = -pi / 2; // Comenzar desde arriba (90 grados)

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final percentage =
          item.percent / 100; // Convertir el porcentaje a una proporción
      final sweepAngle = 2 * pi * percentage;

      // Dibujar segmento
      final paint =
          Paint()
            ..color = item.color
            ..style = PaintingStyle.fill
            ..strokeWidth = strokeWidth;

      final path =
          Path()
            ..moveTo(
              center.dx + innerRadius * cos(startAngle),
              center.dy + innerRadius * sin(startAngle),
            )
            ..lineTo(
              center.dx + outerRadius * cos(startAngle),
              center.dy + outerRadius * sin(startAngle),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: outerRadius),
              startAngle,
              sweepAngle,
              false,
            )
            ..lineTo(
              center.dx + innerRadius * cos(startAngle + sweepAngle),
              center.dy + innerRadius * sin(startAngle + sweepAngle),
            )
            ..arcTo(
              Rect.fromCircle(center: center, radius: innerRadius),
              startAngle + sweepAngle,
              -sweepAngle,
              false,
            )
            ..close();

      canvas.drawPath(path, paint);

      // Dibujar porcentaje si está habilitado
      if (showPercentageLabels && sweepAngle > 0.3) {
        // Solo mostrar si el segmento es lo suficientemente grande
        final percentageText = '${item.percent.toStringAsFixed(0)}%';
        final midAngle = startAngle + sweepAngle / 2;
        final labelRadius = innerRadius + (outerRadius - innerRadius) / 2;
        final labelPosition = Offset(
          center.dx + labelRadius * cos(midAngle),
          center.dy + labelRadius * sin(midAngle),
        );

        final textPainter = TextPainter(
          text: TextSpan(text: percentageText, style: percentageTextStyle),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            labelPosition.dx - textPainter.width / 2,
            labelPosition.dy - textPainter.height / 2,
          ),
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(DonutChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.total != total ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.innerRadiusRatio != innerRadiusRatio;
  }
}
