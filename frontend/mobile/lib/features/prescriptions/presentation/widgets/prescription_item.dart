import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

class PrescriptionItem extends StatelessWidget {
  final Prescription prescription;
  final ValueChanged<bool> onStatusChanged;
  final VoidCallback? onDelete;

  const PrescriptionItem({
    super.key,
    required this.prescription,
    required this.onStatusChanged,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final urgency = prescription.urgency ?? 'MEDIUM';
    final urgencyColor = _getUrgencyColor(urgency);
    final isUrgent = urgency == 'HIGH' || urgency == 'URGENT';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: urgencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: urgencyColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detailed-prescription',
            arguments: {
              'title': prescription.title ?? prescription.parameter,
              'status': urgency,
              'details': prescription.recommendation,
              'category': prescription.category ?? 'general',
              'time': prescription.timeline ?? 'Today',
              'color': urgencyColor,
              'isActive': isUrgent,
              'materials': prescription.materials ?? [],
              'instructions': prescription.instructions ?? [],
              'estimatedDuration': prescription.estimatedDuration ?? '1 hour',
              'fieldName': prescription.fieldName ?? 'Main Field',
              'soilType': prescription.soilType ?? 'Loam',
              'growthStage': prescription.growthStage,
              'dueDate': prescription.dueDate,
              'urgency': urgency,
            },
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Simple icon
                  Container(
                width: 32.w,
                height: 32.h,
                    decoration: BoxDecoration(
                  color: urgencyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getCategoryIcon(prescription.category ?? 'general'),
                  color: urgencyColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Main content - essential info only
                  Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prescription.title ?? prescription.parameter,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
              Text(
                      prescription.recommendation,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Simple urgency indicator and checkbox
              Column(
                children: [
                  // Urgency dot
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: urgencyColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Checkbox
                  GestureDetector(
                    onTap: () => onStatusChanged(!prescription.isCompleted),
                    child: Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: prescription.isCompleted ? Colors.green : urgencyColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                        color: prescription.isCompleted ? Colors.green : Colors.transparent,
                      ),
                      child: prescription.isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12.sp,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilization':
        return Icons.eco;
      case 'weather':
        return Icons.wb_sunny;
      case 'monitoring':
        return Icons.monitor;
      case 'humidity_control':
        return Icons.opacity;
      case 'temperature_control':
        return Icons.thermostat;
      case 'general':
        return Icons.assignment;
      default:
        return Icons.agriculture;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation':
        return Colors.blue[600]!;
      case 'fertilization':
        return Colors.green[600]!;
      case 'weather':
        return Colors.cyan[600]!;
      case 'monitoring':
        return Colors.purple[600]!;
      case 'humidity_control':
        return Colors.teal[600]!;
      case 'temperature_control':
        return Colors.red[400]!;
      case 'general':
        return MAIZE_ACCENT;
      default:
        return Colors.orange[600]!;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return Colors.red[600]!;
      case 'HIGH':
        return Colors.orange[600]!;
      case 'MEDIUM':
        return MAIZE_PRIMARY;
      case 'LOW':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
