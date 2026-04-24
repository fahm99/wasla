import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilter;
  final bool showFilter;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onFilter,
    this.showFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.search, color: AppTheme.greyText, size: 22),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: AppTheme.darkText,
              ),
              decoration: const InputDecoration(
                hintText: 'ابحث عن دورة...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: AppTheme.greyText,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.greyText, size: 20),
              onPressed: () {
                controller.clear();
                onClear?.call();
              },
            ),
          if (showFilter)
            Container(
              width: 1,
              height: 24,
              color: AppTheme.lightGrey,
            ),
          if (showFilter)
            IconButton(
              icon: const Icon(Icons.tune, color: AppTheme.primaryBlue, size: 20),
              onPressed: onFilter,
            ),
        ],
      ),
    );
  }
}
