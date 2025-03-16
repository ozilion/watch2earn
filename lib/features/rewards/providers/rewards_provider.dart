// lib/features/rewards/providers/rewards_provider.dart
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/rewards/models/reward_history.dart';
import 'package:watch2earn/features/rewards/models/rewards_state.dart';
import 'package:watch2earn/features/rewards/services/ad_manager.dart';
import 'package:watch2earn/features/rewards/services/rewards_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final adManagerProvider = Provider<AdManager>((ref) {
  return AdManager();
});

final rewardsServiceProvider = Provider<RewardsService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return RewardsServiceImpl(
    secureStorage: secureStorage,
    authRepository: authRepository,
  );
});

final rewardsControllerProvider =
StateNotifierProvider<RewardsController, AsyncValue<RewardsState>>((ref) {
  final rewardsService = ref.watch(rewardsServiceProvider);
  final adManager = ref.watch(adManagerProvider);
  final authController = ref.watch(authControllerProvider.notifier);
  return RewardsController(
    rewardsService: rewardsService,
    adManager: adManager,
    authController: authController,
  );
});

class RewardsController extends StateNotifier<AsyncValue<RewardsState>> {
  final RewardsService _rewardsService;
  final AdManager _adManager;
  final AuthController _authController;

  RewardsController({
    required RewardsService rewardsService,
    required AdManager adManager,
    required AuthController authController,
  })  : _rewardsService = rewardsService,
        _adManager = adManager,
        _authController = authController,
        super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    developer.log('Initializing RewardsController', name: 'RewardsController');

    // Initial state
    state = AsyncValue.data(RewardsState.initial());

    try {
      // Load initial ad
      await _adManager.loadRewardedAd();

      // Update ad availability state
      final isAdAvailable = _adManager.isRewardedAdLoaded;

      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isAdAvailable: isAdAvailable,
      ) ??
          RewardsState.initial().copyWith(
            isAdAvailable: isAdAvailable,
          ));

      developer.log('RewardsController initialized, ad status: $isAdAvailable',
          name: 'RewardsController');
    } catch (e) {
      developer.log('Error initializing RewardsController: $e',
          name: 'RewardsController', error: e);
      // Continue despite error, allowing the app to function with reduced features
    }
  }

  Future<void> loadRewardHistory(String userId) async {
    developer.log('Loading reward history for user: $userId',
        name: 'RewardsController');

    // Preserve current state while loading
    final currentHistory = state.valueOrNull?.history ?? [];
    final isAdAvailable = state.valueOrNull?.isAdAvailable ?? false;

    state = AsyncValue.data(state.valueOrNull?.copyWith(
      isLoading: true,
    ) ??
        RewardsState.initial().copyWith(
          isLoading: true,
          history: currentHistory,
          isAdAvailable: isAdAvailable,
        ));

    try {
      final result = await _rewardsService.getHistory(userId);

      result.fold(
            (failure) {
          developer.log('Failed to load reward history: ${failure.message}',
              name: 'RewardsController');
          state = AsyncValue.data(state.valueOrNull?.copyWith(
            isLoading: false,
            error: failure.message,
          ) ??
              RewardsState.initial().copyWith(
                isLoading: false,
                history: currentHistory,
                isAdAvailable: isAdAvailable,
                error: failure.message,
              ));
        },
            (history) {
          developer.log('Successfully loaded ${history.length} reward history items',
              name: 'RewardsController');
          state = AsyncValue.data(state.valueOrNull?.copyWith(
            history: history,
            isLoading: false,
            clearError: true,
          ) ??
              RewardsState.initial().copyWith(
                history: history,
                isLoading: false,
                isAdAvailable: isAdAvailable,
              ));
        },
      );
    } catch (e) {
      developer.log('Exception in loadRewardHistory: $e',
          name: 'RewardsController', error: e);
      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isLoading: false,
        error: e.toString(),
      ) ??
          RewardsState.initial().copyWith(
            isLoading: false,
            history: currentHistory,
            isAdAvailable: isAdAvailable,
            error: e.toString(),
          ));
    }

    // Check ad status and update
    _updateAdAvailability();
  }

  Future<void> watchRewardedAd(String userId) async {
    developer.log('Starting rewarded ad flow for user: $userId', name: 'RewardsController');

    // Keep current history but update loading and ad state
    final currentHistory = state.valueOrNull?.history ?? [];

    state = AsyncValue.data(state.valueOrNull?.copyWith(
      isLoading: true,
      isAdAvailable: false, // Ad is not available while showing
      clearError: true,
    ) ??
        RewardsState.initial().copyWith(
          isLoading: true,
          history: currentHistory,
          isAdAvailable: false,
        ));

    try {
      // Show ad and process reward
      await _adManager.showRewardedAd((rewardAmount) async {
        developer.log('Ad completed, adding $rewardAmount token reward',
            name: 'RewardsController');

        try {
          // Add reward to user balance
          final result = await _rewardsService.addReward(userId, rewardAmount);

          result.fold(
                (failure) {
              developer.log('Failed to add reward: ${failure.message}',
                  name: 'RewardsController');
              state = AsyncValue.data(state.valueOrNull?.copyWith(
                isLoading: false,
                error: failure.message,
              ) ??
                  RewardsState.initial().copyWith(
                    isLoading: false,
                    history: currentHistory,
                    error: failure.message,
                  ));
            },
                (newUser) async {
              developer.log('Reward added successfully, new balance: ${newUser.tokenBalance}',
                  name: 'RewardsController');

              // Update user data in auth controller
              await _authController.updateUserData(newUser);
              developer.log('User data updated in auth controller',
                  name: 'RewardsController');

              // Refresh reward history
              loadRewardHistory(userId);
            },
          );
        } catch (e) {
          developer.log('Error processing reward: $e',
              name: 'RewardsController', error: e);
          state = AsyncValue.data(state.valueOrNull?.copyWith(
            isLoading: false,
            error: e.toString(),
          ) ??
              RewardsState.initial().copyWith(
                isLoading: false,
                history: currentHistory,
                error: e.toString(),
              ));
        }
      });
    } catch (e) {
      developer.log('Error in watchRewardedAd: $e',
          name: 'RewardsController', error: e);
      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isLoading: false,
        error: e.toString(),
      ) ??
          RewardsState.initial().copyWith(
            isLoading: false,
            history: currentHistory,
            error: e.toString(),
          ));
    } finally {
      // Reset loading state regardless of outcome
      if (mounted) {
        state = AsyncValue.data(state.valueOrNull?.copyWith(
          isLoading: false,
        ) ??
            RewardsState.initial().copyWith(
              isLoading: false,
              history: currentHistory,
            ));
      }

      // Check ad availability and update state
      _updateAdAvailability();
    }
  }

  // Update ad availability in state
  void _updateAdAvailability() {
    final isAdAvailable = _adManager.isRewardedAdLoaded;

    // Update state if availability changed
    if (state.valueOrNull?.isAdAvailable != isAdAvailable) {
      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isAdAvailable: isAdAvailable,
      ) ??
          RewardsState.initial().copyWith(
            isAdAvailable: isAdAvailable,
          ));

      developer.log('Ad availability updated: $isAdAvailable',
          name: 'RewardsController');
    }

    // If ad not available, try to load
    if (!isAdAvailable) {
      _adManager.loadRewardedAd();
    }
  }

  @override
  void dispose() {
    try {
      _adManager.dispose();
    } catch (e) {
      developer.log('Error disposing AdManager: $e',
          name: 'RewardsController', error: e);
    }
    super.dispose();
  }
}