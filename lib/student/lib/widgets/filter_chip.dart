import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Color? selectedColor;
  final Color? selectedTextColor;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.selectedColor,
    this.selectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return RawChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected
              ? (selectedTextColor ?? AppTheme.white)
              : AppTheme.greyText,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: AppTheme.white,
      selectedColor: selectedColor ?? AppTheme.primaryBlue,
      side: BorderSide(
        color: selected
            ? (selectedColor ?? AppTheme.primaryBlue)
            : AppTheme.lightGrey,
        width: 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      showCheckmark: false,
    );
  }
}
