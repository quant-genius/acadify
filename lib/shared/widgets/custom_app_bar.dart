
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Custom app bar used throughout the app
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title of the app bar
  final String title;
  
  /// Whether to show a back button
  final bool showBackButton;
  
  /// Actions to display on the right side of the app bar
  final List<Widget>? actions;
  
  /// Function called when the back button is pressed
  final VoidCallback? onBackPressed;
  
  /// Whether the app bar should have a shadow
  final bool hasShadow;
  
  /// Background color of the app bar
  final Color? backgroundColor;
  
  /// Creates a CustomAppBar
  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
    this.hasShadow = true,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor ?? Colors.white,
      elevation: hasShadow ? 2 : 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: hasShadow
            ? Container(
                height: 1,
                color: Colors.grey.withOpacity(0.2),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
