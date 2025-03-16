import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

enum AppBarStyle {
  regular,
  transparent,
  gradient,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final AppBarStyle style;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final List<Widget>? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.style = AppBarStyle.regular,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.onBackPressed,
    this.showBackButton = true,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on style and theme
    final Color effectiveBackgroundColor = backgroundColor ??
        (style == AppBarStyle.transparent
            ? Colors.transparent
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface));

    final Color effectiveIconColor = iconColor ??
        (style == AppBarStyle.transparent
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? AppColors.darkTextColor : AppColors.lightTextColor));

    final Color effectiveTitleColor = titleColor ??
        (style == AppBarStyle.transparent
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? AppColors.darkTextColor : AppColors.lightTextColor));

    // Set system UI overlay style based on theme and style
    final systemOverlayStyle = (isDark || style == AppBarStyle.transparent)
        ? SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    )
        : SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );

    Widget appBar = AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          color: effectiveTitleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      leading: leading ?? (showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      )
          : null),
      actions: actions,
      elevation: elevation,
      backgroundColor: effectiveBackgroundColor,
      iconTheme: IconThemeData(
        color: effectiveIconColor,
      ),
      systemOverlayStyle: systemOverlayStyle,
      bottom: bottom != null
          ? PreferredSize(
        preferredSize: Size.fromHeight(bottom!.length * 48.0),
        child: Column(children: bottom!),
      )
          : null,
    );

    // Apply gradient if needed
    if (style == AppBarStyle.gradient) {
      appBar = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: elevation > 0
              ? [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.25),
              blurRadius: elevation * 2,
              offset: Offset(0, elevation),
            ),
          ]
              : null,
        ),
        child: appBar,
      );
    }

    return appBar;
  }

  @override
  Size get preferredSize => bottom != null
      ? Size.fromHeight(kToolbarHeight + (bottom!.length * 48.0))
      : const Size.fromHeight(kToolbarHeight);
}