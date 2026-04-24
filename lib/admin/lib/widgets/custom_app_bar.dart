import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = false,
    this.leading,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AppBar(
        backgroundColor: backgroundColor ?? AppTheme.primaryDarkBlue,
        foregroundColor: AppTheme.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: AppTheme.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : leading,
        actions: actions,
      ),
    );
  }
}
