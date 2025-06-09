// lib/widget/prescription_widget.dart
import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  // Get localized parameter name
  String _getLocalizedParameterName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    switch (prescription.parameter.toLowerCase()) {
      case 'soil_ph':
        return localizations.parameter_soil_ph;
      case 'soil_moisture':
        return localizations.parameter_soil_moisture;
      case 'temperature':
        return localizations.parameter_temperature;
      case 'humidity':
        return localizations.parameter_humidity;
      case 'light_intensity':
        return localizations.parameter_light_intensity;
      default:
        return prescription.parameter.replaceAll('_', ' ').toUpperCase();
    }
  }

  // Get localized recommendation text
  String _getLocalizedRecommendation(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    // Add translations for common recommendations
    final recommendation = prescription.recommendation.toLowerCase();
    if (recommendation.contains('apply') && recommendation.contains('fertilizer')) {
      return localizations.recommendation_apply_fertilizer;
    } else if (recommendation.contains('water') || recommendation.contains('irrigation')) {
      return localizations.recommendation_water;
    } else if (recommendation.contains('temperature') || recommendation.contains('heat')) {
      return localizations.recommendation_temperature;
    } else if (recommendation.contains('ph') || recommendation.contains('soil')) {
      return localizations.recommendation_soil_ph;
    } else if (recommendation.contains('light') || recommendation.contains('shade')) {
      return localizations.recommendation_light;
    }
    // If no specific translation is found, return the original recommendation
    return prescription.recommendation;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getPriorityColor(),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: _getLocalizedParameterName(context),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      CustomFont(
                        text: '${prescription.value} (${prescription.status})',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      if (prescription.recommendation.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: CustomFont(
                            text: _getLocalizedRecommendation(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
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
                          size: 28,
                        ),
                        onPressed: onDelete,
                        tooltip: localizations.tooltip_delete_prescription,
                      ),
                    Transform.scale(
                      scale: 1.4,
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
            const SizedBox(height: 12),
            // Date and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    CustomFont(
                      text: date,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    CustomFont(
                      text: time,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ],
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
