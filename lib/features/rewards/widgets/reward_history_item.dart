import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/rewards/models/reward_history.dart';

import '../../../core/theme/modern_widgets.dart';
import '../../../core/theme/text_styles.dart';

class RewardHistoryItem extends StatelessWidget {
  final RewardHistory reward;

  const RewardHistoryItem({
    Key? key,
    required this.reward,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return BounceCard(
      padding: const EdgeInsets.all(16),
      showBorder: true,
      borderColor: AppColors.lightDividerColor,
      elevation: 1,
      boxShadow: [
        BoxShadow(
          color: AppColors.tokenColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
      onTap: () {}, // İsterseniz detay göstermek için işlev ekleyebilirsiniz
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getIconForRewardType(reward.type),
                color: AppColors.primaryColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.readableType,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(reward.createdAt),
                  style: AppTextStyles.bodyTextSmall.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '+${reward.amount} TOKEN',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: 12,
                color: AppColors.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForRewardType(RewardType type) {
    switch (type) {
      case RewardType.adReward:
        return Icons.play_circle_outline;
      case RewardType.signupBonus:
        return Icons.person_add;
      case RewardType.dailyLogin:
        return Icons.calendar_today;
      case RewardType.watchMovie:
        return Icons.movie;
      case RewardType.watchEpisode:
        return Icons.live_tv;
      case RewardType.earned:
        return Icons.workspace_premium;
      case RewardType.levelUp:
        return Icons.trending_up;
      case RewardType.other:
        return Icons.token;
    }
  }
}