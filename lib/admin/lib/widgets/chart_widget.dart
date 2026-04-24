import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class ChartWidget extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? trailing;

  const ChartWidget({
    super.key,
    required this.child,
    this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryDarkBlue,
                          ),
                        ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
