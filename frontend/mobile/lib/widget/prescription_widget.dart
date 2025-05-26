// lib/widget/prescription_widget.dart
import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import '../model/prescription_model.dart';

class PrescriptionWidget extends StatelessWidget {
  final Prescription prescription;
  final Function(bool) onStatusChanged;
  final Function()? onDelete;
  final Function()? onCheckAll;
  final Function()? onUncheckAll;
  final Function()? onDeleteAll;
  final Function()? onDeleteCompleted;

  const PrescriptionWidget({
    Key? key,
    required this.prescription,
    required this.onStatusChanged,
    this.onDelete,
    this.onCheckAll,
    this.onUncheckAll,
    this.onDeleteAll,
    this.onDeleteCompleted,
  }) : super(key: key);

  // Get the color based on priority
  Color _getPriorityColor() {
    switch (prescription.priority) {
      case 1:
        return Colors.red.shade700; // High priority
      case 2:
        return Colors.orange.shade700; // Medium priority
      case 3:
        return Colors.green.shade700; // Low priority
      default:
        return Colors.blue.shade700; // Default
    }
  }

  // Get category icon
  IconData _getCategoryIcon() {
    switch (prescription.parameter.toLowerCase()) {
      case 'soil_ph':
        return Icons.science;
      case 'soil_moisture':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water;
      case 'light_intensity':
        return Icons.light_mode;
      default:
        return Icons.recommend;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = prescription.timestamp;
    final date = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: _getPriorityColor().withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getPriorityColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: prescription.parameter
                            .replaceAll('_', ' ')
                            .toUpperCase(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      CustomFont(
                        text: '${prescription.value} (${prescription.status})',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      if (prescription.recommendation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        CustomFont(
                          text: prescription.recommendation,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ],
                    ],
                  ),
                ),
                // Checkbox and delete button
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prescription.isCompleted && onDelete != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                        ),
                        onPressed: onDelete,
                        tooltip: 'Delete prescription',
                      ),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: prescription.isCompleted,
                        onChanged: (value) {
                          if (value != null) {
                            onStatusChanged(value);
                          }
                        },
                        activeColor: MAIZE_PRIMARY,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Date and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    CustomFont(
                      text: date,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    CustomFont(
                      text: time,
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                // Impact score
                if (prescription.impactScore > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomFont(
                      text:
                          '${(prescription.impactScore * 100).toStringAsFixed(0)}% Impact',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getPriorityColor(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Function()? onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
