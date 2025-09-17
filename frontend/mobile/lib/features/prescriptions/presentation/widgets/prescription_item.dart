import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/core/theme/colors.dart';
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
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, y • hh:mm a');
    final statusColor = _getStatusColor(theme);
    final statusIcon = _getStatusIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Handle tap to view details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Parameter name
                  Expanded(
                    child: Text(
                      prescription.parameter,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Status icon
                  Icon(statusIcon, color: statusColor, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              // Value and recommendation
              Text(
                '${prescription.value} • ${prescription.recommendation}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              // Growth stage and impact score
              Row(
                children: [
                  _buildChip(
                    context,
                    label: prescription.growthStage,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    context,
                    label:
                        'Impact: ${prescription.impactScore.toStringAsFixed(1)}',
                    backgroundColor: _getImpactColor(
                      theme,
                      prescription.impactScore,
                    ).withOpacity(0.2),
                    textColor: _getImpactColor(theme, prescription.impactScore),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Timestamp and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(prescription.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Row(
                    children: [
                      // Toggle completion
                      IconButton(
                        icon: Icon(
                          prescription.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              prescription.isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.hintColor,
                        ),
                        onPressed:
                            () => onStatusChanged(!prescription.isCompleted),
                        tooltip:
                            prescription.isCompleted
                                ? 'Mark as incomplete'
                                : 'Mark as complete',
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // Delete button (only for completed prescriptions)
                      if (prescription.isCompleted && onDelete != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: onDelete,
                          tooltip: 'Delete prescription',
                          iconSize: 24,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: theme.colorScheme.error,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required Color backgroundColor,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    if (prescription.isCompleted) {
      return theme.colorScheme.primary;
    }

    switch (prescription.status) {
      case PrescriptionStatus.high:
        return theme.colorScheme.error;
      case PrescriptionStatus.medium:
        return theme.colorScheme.tertiary;
      case PrescriptionStatus.low:
      default:
        return theme.colorScheme.tertiaryContainer;
    }
  }

  IconData _getStatusIcon() {
    if (prescription.isCompleted) {
      return Icons.check_circle_outline;
    }

    switch (prescription.status) {
      case PrescriptionStatus.high:
        return Icons.priority_high;
      case PrescriptionStatus.medium:
        return Icons.warning_amber_rounded;
      case PrescriptionStatus.low:
      default:
        return Icons.info_outline;
    }
  }

  Color _getImpactColor(ThemeData theme, double impact) {
    if (impact >= 7) {
      return theme.colorScheme.error;
    } else if (impact >= 4) {
      return theme.colorScheme.tertiary;
    } else {
      return theme.colorScheme.tertiaryContainer;
    }
  }
}
