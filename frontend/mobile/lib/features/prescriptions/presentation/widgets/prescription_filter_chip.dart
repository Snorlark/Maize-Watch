import 'package:flutter/material.dart';

class PrescriptionFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const PrescriptionFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected 
            ? theme.colorScheme.onPrimary 
            : theme.colorScheme.onSurfaceVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceVariant,
      selectedColor: theme.colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    );
  }
}
