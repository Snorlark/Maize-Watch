// lib/widget/prescription_widget.dart
import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/prescription_model.dart';

class PrescriptionWidget extends StatelessWidget {
  final String title;
  final String value;
  final String date;
  final String time;
  final bool isChecked;
  final Function(bool) onChecked;
  final String? category;
  final int? priority;
  final String? description;

  const PrescriptionWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.date,
    required this.time,
    required this.isChecked,
    required this.onChecked,
    this.category,
    this.priority,
    this.description,
  }) : super(key: key);

  // Get the color based on priority
  Color _getPriorityColor() {
    if (priority == null) return Colors.blue.shade700;
    
    switch (priority) {
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
    if (category == null) return Icons.recommend;
    
    switch (category!.toLowerCase()) {
      case 'soil ph':
        return Icons.science;
      case 'moisture':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      case 'nutrition':
        return Icons.eco;
      case 'pest':
        return Icons.bug_report;
      case 'disease':
        return Icons.coronavirus;
      default:
        return Icons.recommend;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        text: title,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      const SizedBox(height: 4),
                      CustomFont(
                        text: value,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                      if (description != null && description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        CustomFont(
                          text: description!,
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.black54,
                        ),
                      ],
                    ],
                  ),
                ),
                // Checkbox
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      if (value != null) {
                        onChecked(value);
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
            const SizedBox(height: 10),
            // Date, time and priority indicator
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
                if (priority != null) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getPriorityColor().withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: CustomFont(
                    text: priority == 1 ? 'High' : (priority == 2 ? 'Medium' : 'Low'),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
}