// lib/features/profile/widgets/profile_menu_item.dart
import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/modern_widgets.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showBadge;
  final int badgeCount;
  final Color? iconColor;
  final Color? backgroundColor;
  final Widget? trailing;
  final bool showDivider;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.showBadge = false,
    this.badgeCount = 0,
    this.iconColor,
    this.backgroundColor,
    this.trailing,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primary.withOpacity(0.08);

    return Column(
      children: [
        BounceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          onTap: onTap,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          color: Colors.transparent,
          borderRadius: 16,
          boxShadow: const [],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: effectiveIconColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodyTextSmall.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 72,
            endIndent: 16,
            color: theme.dividerColor.withOpacity(0.3),
          ),
      ],
    );
  }
}