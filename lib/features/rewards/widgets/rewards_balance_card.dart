import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';
import 'package:watch2earn/features/auth/widgets/auth_button.dart';

class RewardsBalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onWatchAdPressed;
  final bool isWatchingAd;

  const RewardsBalanceCard({
    Key? key,
    required this.balance,
    this.onWatchAdPressed,
    this.isWatchingAd = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'tokens.balance'.tr(),
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on,
                color: AppColors.tokenColor,
                size: 36,
              ),
              const SizedBox(width: 8),
              Text(
                balance.toStringAsFixed(1),
                style: AppTextStyles.headlineLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'tokens.watch_ads'.tr(),
            style: AppTextStyles.bodyText.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: AuthButton(
              text: 'tokens.watch_ad'.tr(),
              icon: Icons.ondemand_video,
              onPressed: onWatchAdPressed,
              isLoading: isWatchingAd,
            ),
          ),
        ],
      ),
    );
  }
}
