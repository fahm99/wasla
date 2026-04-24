import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final Color? selectedColor;
  final Color? unselectedColor;

  const TabBarWidget({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final sc = selectedColor ?? AppTheme.primaryDarkBlue;
    final uc = unselectedColor ?? AppTheme.darkGrayText;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.lightGrayBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? sc : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: sc.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppTheme.white : uc,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
