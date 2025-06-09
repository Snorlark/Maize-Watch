import 'package:flutter/material.dart';

class SensorDataWidget extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final IconData icon;

  const SensorDataWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
  }) : super(key: key);

  Color _getValueColor() {
    switch (title.toLowerCase()) {
      case 'temperature':
        if (value < 15) return Colors.blue;
        if (value > 35) return Colors.red;
        return Colors.green;
      case 'humidity':
        if (value < 40) return Colors.orange;
        if (value > 80) return Colors.red;
        return Colors.green;
      case 'soil moisture':
        if (value < 30) return Colors.orange;
        if (value > 80) return Colors.red;
        return Colors.green;
      case 'light level':
        if (value < 1000) return Colors.orange;
        if (value > 10000) return Colors.red;
        return Colors.green;
      case 'soil ph':
        if (value < 5.5) return Colors.orange;
        if (value > 7.5) return Colors.orange;
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: _getValueColor(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontSize: 14,
                      color: _getValueColor(),
                    ),
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