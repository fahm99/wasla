import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
    this.actions,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryBlue;
    final txtColor = textColor ?? AppTheme.white;

    return AppBar(
      backgroundColor: bgColor,
      foregroundColor: txtColor,
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: txtColor,
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: txtColor, size: 20),
              onPressed: () => context.pop(),
            )
          : null,
      actions: actions,
    );
  }
}
