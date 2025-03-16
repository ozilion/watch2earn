// lib/features/rewards/screens/rewards_screen.dart
import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/modern_widgets.dart';
import 'package:watch2earn/core/theme/text_styles.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/rewards/models/reward_history.dart';
import 'package:watch2earn/features/rewards/providers/rewards_provider.dart';
import 'package:watch2earn/features/rewards/widgets/reward_history_item.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRewardHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadRewardHistory() {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user != null) {
      ref.read(rewardsControllerProvider.notifier).loadRewardHistory(user.id);
    } else {
      developer.log('Cannot load reward history - user is null', name: 'RewardsScreen');
    }
  }

  void _onWatchAdPressed() async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      // Show watching ad message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('tokens.watching_ad'.tr()),
          backgroundColor: AppColors.infoColor,
          duration: const Duration(seconds: 1),
        ),
      );

      try {
        await ref.read(rewardsControllerProvider.notifier).watchRewardedAd(user.id);

        // Show success message after ad completes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('tokens.rewarded'.tr().replaceAll('{count}', '5')),
              backgroundColor: AppColors.successColor,
            ),
          );
        }
      } catch (e) {
        // Show error if something went wrong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final rewardsState = ref.watch(rewardsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('tokens.earn'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRewardHistory,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.tokenColor,
          indicatorWeight: 3,
          labelColor: AppColors.tokenColor,
          tabs: [
            Tab(text: 'tokens.earn'.tr()),
            Tab(text: 'tokens.history'.tr()),
          ],
        ),
        elevation: 0,
      ),
      body: authState.when(
        data: (authData) {
          // If user isn't authenticated, show login prompt
          if (authData.user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Please log in to earn tokens',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create an account to start earning and tracking your rewards!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // User is authenticated, show rewards tabs
          return TabBarView(
            controller: _tabController,
            children: [
              // Earn Tab
              _buildEarnTokensTab(authData.user!, rewardsState),

              // History Tab
              _buildHistoryTab(rewardsState),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (error, stack) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(authControllerProvider),
        ),
      ),
    );
  }

  Widget _buildEarnTokensTab(dynamic user, AsyncValue<dynamic> rewardsState) {
    return rewardsState.when(
      data: (state) {
        final isAdAvailable = state.isAdAvailable;
        final isLoading = _isLoading || state.isLoading;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Token balance card
                  _buildTokenBalanceCard(user),
                  const SizedBox(height: 24),

                  // Earning methods title
                  Text(
                    'Earning Methods',
                    style: AppTextStyles.sectionHeader,
                  ),
                  const SizedBox(height: 16),

                  // Watch ads card
                  _buildEarningMethodCard(
                    icon: Icons.ondemand_video,
                    title: 'Watch Ads',
                    description: 'tokens.watch_ads'.tr(),
                    tokenReward: '5',
                    isAvailable: isAdAvailable,
                    isLoading: isLoading,
                    onTap: isAdAvailable && !isLoading ? _onWatchAdPressed : null,
                  ),

                  // Daily login card
                  _buildEarningMethodCard(
                    icon: Icons.calendar_today,
                    title: 'Daily Login',
                    description: 'Log in every day to earn tokens',
                    tokenReward: '2',
                    isAvailable: false, // This would come from the backend
                    isLoading: false,
                    comingSoon: false,
                    unavailableMessage: 'Already claimed today. Come back tomorrow!',
                    onTap: null,
                  ),

                  // Watch content card
                  _buildEarningMethodCard(
                    icon: Icons.movie,
                    title: 'Watch Content',
                    description: 'Earn tokens by watching movies and TV shows',
                    tokenReward: '10',
                    isAvailable: true,
                    isLoading: false,
                    onTap: () {
                      // Navigate to content
                    },
                  ),

                  // Complete profile
                  _buildEarningMethodCard(
                    icon: Icons.person,
                    title: 'Complete Profile',
                    description: 'Add your information to earn a bonus',
                    tokenReward: '20',
                    isAvailable: false, // This would come from the backend
                    isLoading: false,
                    comingSoon: true,
                    onTap: null,
                  ),

                  // Error message if any
                  if (state.error != null)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: _loadRewardHistory,
      ),
    );
  }

  Widget _buildHistoryTab(AsyncValue<dynamic> rewardsState) {
    return rewardsState.when(
      data: (state) {
        if (state.history.isEmpty) {
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'tokens.token_history_empty'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start earning tokens by watching ads and content!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: state.history.length + 1, // +1 for the header
            itemBuilder: (context, index) {
              if (index == 0) {
                // Header with summary
                return _buildHistorySummary(state.history);
              }

              // History items
              final historyItem = state.history[index - 1];
              return AnimatedListItem(
                index: index - 1,
                itemCount: state.history.length,
                child: RewardHistoryItem(
                  reward: historyItem,
                ),
              );
            },
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (error, stack) => ErrorView(
        message: error.toString(),
        onRetry: _loadRewardHistory,
      ),
    );
  }

  Widget _buildTokenBalanceCard(dynamic user) {
    return GradientContainer(
      colors: AppColors.tokenGradient,
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.tokenColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'tokens.balance'.tr(),
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      AnimatedCounter(
                        value: user.tokenBalance,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        precision: 1,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/token_icon.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar to next level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level 1',
                    style: AppTextStyles.bodyText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Level 2',
                    style: AppTextStyles.bodyText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CustomProgressIndicator(
                value: user.tokenBalance / 100, // Assuming 100 is the goal
                height: 10,
                backgroundColor: Colors.white.withOpacity(0.3),
                progressColors: const [Colors.white, Colors.white],
              ),
              const SizedBox(height: 8),
              Text(
                'Earn ${(100 - user.tokenBalance).toStringAsFixed(1)} more tokens to reach Level 2',
                style: AppTextStyles.bodyTextSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningMethodCard({
    required IconData icon,
    required String title,
    required String description,
    required String tokenReward,
    required bool isAvailable,
    required bool isLoading,
    bool comingSoon = false,
    String? unavailableMessage,
    VoidCallback? onTap,
  }) {
    final isDisabled = !isAvailable || isLoading || comingSoon;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isAvailable && !comingSoon
            ? BorderSide(color: AppColors.primaryColor.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      elevation: isAvailable && !comingSoon ? 3 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAvailable && !comingSoon
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 30,
                    color: isAvailable && !comingSoon ? AppColors.primaryColor : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: isDisabled
                                ? Colors.grey
                                : Theme.of(context).textTheme.titleSmall!.color,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isAvailable && !comingSoon
                                ? AppColors.tokenColor.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                size: 14,
                                color: isAvailable && !comingSoon ? AppColors.tokenColor : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tokenReward,
                                style: TextStyle(
                                  color: isAvailable && !comingSoon ? AppColors.tokenColor : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: isDisabled
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
                      ),
                    ),
                    if (comingSoon) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: TextStyle(
                            color: AppColors.infoColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (!isAvailable && !comingSoon && unavailableMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        unavailableMessage,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAvailable && !comingSoon && !isLoading) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                ),
              ],
              if (isLoading) ...[
                const SizedBox(width: 16),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySummary(List<RewardHistory> history) {
    // Calculate total earnings
    final totalEarned = history.fold<double>(
      0,
          (total, item) => total + item.amount,
    );

    // Get today's earnings
    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final todayEarned = history
        .where((item) => item.createdAt.isAfter(todayStart))
        .fold<double>(
      0,
          (total, item) => total + item.amount,
    );

    // Get this week's earnings
    final weekStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day - DateTime.now().weekday + 1,
    );
    final weekEarned = history
        .where((item) => item.createdAt.isAfter(weekStart))
        .fold<double>(
      0,
          (total, item) => total + item.amount,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Summary',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSummaryItem(
                  context,
                  'Total',
                  totalEarned.toStringAsFixed(1),
                  Icons.monetization_on,
                  AppColors.primaryColor,
                ),
                const SizedBox(width: 16),
                _buildSummaryItem(
                  context,
                  'Today',
                  todayEarned.toStringAsFixed(1),
                  Icons.today,
                  AppColors.secondaryColor,
                ),
                const SizedBox(width: 16),
                _buildSummaryItem(
                  context,
                  'This Week',
                  weekEarned.toStringAsFixed(1),
                  Icons.date_range,
                  AppColors.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}