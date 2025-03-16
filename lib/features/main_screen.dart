import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    Key? key,
    required this.navigationShell,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'home.title'.tr(),
                  index: 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'search.title'.tr(),
                  index: 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.favorite_border_outlined,
                  activeIcon: Icons.favorite,
                  label: 'favorites.title'.tr(),
                  index: 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.monetization_on_outlined,
                  activeIcon: Icons.monetization_on,
                  label: 'tokens.earn'.tr(),
                  index: 3,
                  showGlowForToken: true,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'profile.title'.tr(),
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool showGlowForToken = false,
  }) {
    final isSelected = index == navigationShell.currentIndex;
    final theme = Theme.of(context);
    final primaryColor = AppColors.primaryColor;
    final unselectedColor = theme.brightness == Brightness.light
        ? AppColors.lightTextColor.withOpacity(0.6)
        : AppColors.darkTextColor.withOpacity(0.6);

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with potential glowing effect for token tab
            Stack(
              alignment: Alignment.center,
              children: [
                if (showGlowForToken && isSelected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tokenColor.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? (showGlowForToken ? AppColors.tokenColor : primaryColor)
                      : unselectedColor,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Label
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? (showGlowForToken ? AppColors.tokenColor : primaryColor)
                    : unselectedColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}