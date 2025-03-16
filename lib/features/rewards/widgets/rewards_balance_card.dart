import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/modern_widgets.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

class TokenBalanceWidget extends StatelessWidget {
  final double balance;
  final VoidCallback onTap;

  const TokenBalanceWidget({
    Key? key,
    required this.balance,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BounceCard(
      onTap: onTap,
      boxShadow: [
        BoxShadow(
          color: AppColors.tokenColor.withOpacity(isDark ? 0.25 : 0.3),
          blurRadius: 15,
          offset: const Offset(0, 6),
          spreadRadius: 1,
        ),
      ],
      gradientColors: [
        AppColors.tokenColor,
        AppColors.tokenSecondaryColor,
      ],
      borderRadius: 20,
      elevation: 4,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          Row(
            children: [
              // Token icon
              _buildTokenIcon(),
              const SizedBox(width: 16),

              // Balance information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOKEN BALANCE',
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        AnimatedCounter(
                          value: balance,
                          style: AppTextStyles.tokenAmount.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                          precision: 1,
                          duration: const Duration(milliseconds: 1500),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'tokens',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow indicator
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTokenIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Animated shimmer effect
          Positioned.fill(
            child: ShimmerEffect(
              baseColor: Colors.transparent,
              highlightColor: Colors.white.withOpacity(0.3),
              duration: const Duration(milliseconds: 2000),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          // Icon
          const Center(
            child: Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}