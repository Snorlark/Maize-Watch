import 'package:flutter/material.dart';
import 'package:mobile/features/live_monitoring/domain/entities/sensor_reading.dart';
import '../../../farm/domain/entities/farm.dart';

class FarmMapWidget extends StatelessWidget {
  final List<Farm> farms;
  final List<SensorReading>? sensorReadings;
  final Function(Farm farm) onFarmSelected;

  const FarmMapWidget({
    super.key,
    required this.farms,
    this.sensorReadings,
    required this.onFarmSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background polygons
          CustomPaint(
            size: Size.infinite,
            painter: _FarmPolygonPainter(farms.length),
          ),

          // Clickable farm circles
          ...farms.asMap().entries.map((entry) {
            final i = entry.key;
            final farm = entry.value;
            final left = 50.0 + (i * 80);
            final top = 50.0 + (i * 50);

            return Positioned(
              left: left,
              top: top,
              child: GestureDetector(
                onTap: () => onFarmSelected(farm),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.green.shade600, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.grass, color: Colors.green),
                      const SizedBox(height: 4),
                      Text(
                        farm.farmName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FarmPolygonPainter extends CustomPainter {
  final int fieldCount;

  _FarmPolygonPainter(this.fieldCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.green.shade50
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = Colors.green.shade300
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    for (var i = 0; i < fieldCount; i++) {
      final dx = (i * 80).toDouble() + 70;
      final dy = (i * 50).toDouble() + 120;

      final path =
          Path()..addOval(Rect.fromCircle(center: Offset(dx, dy), radius: 70));

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
