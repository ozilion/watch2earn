// lib/features/rewards/services/ad_manager.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

typedef RewardCallback = Function(double rewardAmount);

/// AdManager handles all ad-related functionality including loading, showing,
/// and scheduling different types of ads (banner, interstitial, rewarded)
class AdManager {
  // Ad state tracking
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isLoadingAd = false;

  // Track content interactions for ad targeting
  int _contentInteractionCount = 0;

  // Track last ad shown time to prevent excessive ad display
  DateTime? _lastInterstitialShown;
  DateTime? _lastRewardedAdShown;

  // Timer for scheduled ads
  Timer? _scheduledAdTimer;

  // Stream controller for ad countdown
  final _adCountdownController = BehaviorSubject<int>();
  Stream<int> get adCountdown => _adCountdownController.stream;

  // Constants for ads
  static const int scheduledAdIntervalMinutes = 15; // Time between scheduled ads
  static const int minimumAdIntervalSeconds = 90; // Minimum time between ads
  static const int contentInteractionsBeforeAd = 3; // Show ad after this many interactions
  static const double defaultRewardAmount = AppConstants.adRewardAmount; // Default reward amount

  // Ad unit IDs with safe fallbacks
  final String _bannerAdUnitId = kDebugMode
      ? _getSafeAdUnitId('ADMOB_BANNER_ID_TEST', 'ca-app-pub-3940256099942544/6300978111')
      : _getSafeAdUnitId('ADMOB_BANNER_ID', '');

  final String _interstitialAdUnitId = kDebugMode
      ? _getSafeAdUnitId('ADMOB_INTERSTITIAL_ID_TEST', 'ca-app-pub-3940256099942544/1033173712')
      : _getSafeAdUnitId('ADMOB_INTERSTITIAL_ID', '');

  final String _rewardedAdUnitId = kDebugMode
      ? _getSafeAdUnitId('ADMOB_REWARDED_ID_TEST', 'ca-app-pub-3940256099942544/5224354917')
      : _getSafeAdUnitId('ADMOB_REWARDED_ID', '');

  // Ad objects
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Safe getter for ad unit IDs with fallbacks
  static String _getSafeAdUnitId(String envKey, String defaultValue) {
    try {
      final value = dotenv.env[envKey];
      if (value == null || value.isEmpty) {
        developer.log('No valid value found for $envKey, using default', name: 'AdManager');
        return defaultValue;
      }
      return value;
    } catch (e) {
      developer.log('Error getting $envKey: $e, using default', name: 'AdManager', error: e);
      return defaultValue;
    }
  }

  // Constructor
  AdManager() {
    _initAds();
    _startScheduledAdTimer();
  }

  // Initialize ads
  void _initAds() {
    developer.log('Initializing ads', name: 'AdManager');

    // Load initial ads
    loadBannerAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // Start the countdown timer for scheduled ads
  void _startScheduledAdTimer() {
    // Cancel any existing timer
    _scheduledAdTimer?.cancel();

    // Initialize countdown value
    _adCountdownController.add(scheduledAdIntervalMinutes * 60);

    // Create a timer to update the countdown every second
    _scheduledAdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adCountdownController.isClosed) {
        timer.cancel();
        return;
      }

      final currentValue = _adCountdownController.value;
      if (currentValue <= 0) {
        // Reset the countdown
        _adCountdownController.add(scheduledAdIntervalMinutes * 60);

        // Check if we should show a scheduled ad
        _checkAndShowScheduledAd();
      } else {
        // Decrement countdown
        _adCountdownController.add(currentValue - 1);
      }
    });
  }

  // Check if we can show a scheduled ad
  void _checkAndShowScheduledAd() {
    // Don't show if another ad was recently shown
    if (_lastRewardedAdShown != null &&
        DateTime.now().difference(_lastRewardedAdShown!).inSeconds < minimumAdIntervalSeconds) {
      developer.log('Too soon for scheduled ad - skipping', name: 'AdManager');
      return;
    }

    if (_isRewardedAdLoaded) {
      developer.log('Showing scheduled rewarded ad', name: 'AdManager');

      // Add a small delay before showing ad
      Future.delayed(const Duration(seconds: 1), () {
        showRewardedAd((reward) {
          // This is a scheduled ad with no direct user action, so we don't provide a reward
          developer.log('Scheduled ad completed (no reward)', name: 'AdManager');
        });
      });
    } else if (_isInterstitialAdLoaded) {
      developer.log('No rewarded ad available, showing interstitial instead', name: 'AdManager');

      Future.delayed(const Duration(seconds: 1), () {
        showInterstitialAd();
      });
    } else {
      developer.log('No ads available for scheduled showing', name: 'AdManager');
    }
  }

  // Track content interaction (like selecting a movie)
  void trackContentInteraction() {
    _contentInteractionCount++;
    developer.log('Content interaction tracked: $_contentInteractionCount/$contentInteractionsBeforeAd',
        name: 'AdManager');

    // Show ad after reaching threshold
    if (_contentInteractionCount >= contentInteractionsBeforeAd) {
      _contentInteractionCount = 0;

      // Don't show if another ad was recently shown
      if (_lastInterstitialShown != null &&
          DateTime.now().difference(_lastInterstitialShown!).inSeconds < minimumAdIntervalSeconds) {
        developer.log('Too soon for interstitial ad after content interactions - skipping',
            name: 'AdManager');
        return;
      }

      // Prefer rewarded ads, fall back to interstitial
      if (_isRewardedAdLoaded) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showRewardedAd((reward) {
            developer.log('Interaction-based rewarded ad completed with reward: $reward',
                name: 'AdManager');
          });
        });
      } else if (_isInterstitialAdLoaded) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showInterstitialAd();
        });
      } else {
        developer.log('No ads available to show after content interactions', name: 'AdManager');
      }
    }
  }

  // BANNER AD METHODS
  Future<void> loadBannerAd() async {
    if (_isLoadingAd || _isBannerAdLoaded) {
      return;
    }

    try {
      _isLoadingAd = true;
      developer.log('Loading banner ad...', name: 'AdManager');

      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            _isLoadingAd = false;
            developer.log('Banner ad loaded successfully', name: 'AdManager');
          },
          onAdFailedToLoad: (ad, error) {
            _isBannerAdLoaded = false;
            _isLoadingAd = false;
            ad.dispose();
            developer.log('Banner ad failed to load: ${error.message}', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 60), loadBannerAd);
          },
          onAdOpened: (ad) => developer.log('Banner ad opened', name: 'AdManager'),
          onAdClosed: (ad) => developer.log('Banner ad closed', name: 'AdManager'),
          onAdImpression: (ad) => developer.log('Banner ad impression', name: 'AdManager'),
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      _isBannerAdLoaded = false;
      _isLoadingAd = false;
      developer.log('Error loading banner ad: $e', name: 'AdManager', error: e);

      // Retry after delay
      Future.delayed(const Duration(seconds: 60), loadBannerAd);
    }
  }

  // Get banner ad widget
  Widget getBannerAd() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      // Request loading if not already loading
      if (!_isLoadingAd) {
        loadBannerAd();
      }

      // Return placeholder until ad is loaded
      return Container(
        height: 50,
        color: Colors.transparent,
        child: const Center(
          child: Text('Advertisement', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    // Return actual ad
    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // INTERSTITIAL AD METHODS
  Future<void> loadInterstitialAd() async {
    if (_isLoadingAd || _isInterstitialAdLoaded) {
      return;
    }

    try {
      _isLoadingAd = true;
      developer.log('Loading interstitial ad...', name: 'AdManager');

      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _isLoadingAd = false;
            developer.log('Interstitial ad loaded successfully', name: 'AdManager');

            // Set up full-screen callbacks
            _setupInterstitialCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialAdLoaded = false;
            _isLoadingAd = false;
            developer.log('Interstitial ad failed to load: ${error.message}', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 60), loadInterstitialAd);
          },
        ),
      );
    } catch (e) {
      _isInterstitialAdLoaded = false;
      _isLoadingAd = false;
      developer.log('Error loading interstitial ad: $e', name: 'AdManager', error: e);

      // Retry after delay
      Future.delayed(const Duration(seconds: 60), loadInterstitialAd);
    }
  }

  // Setup interstitial ad callbacks
  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log('Interstitial ad showed full screen content', name: 'AdManager');
        _lastInterstitialShown = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('Interstitial ad dismissed', name: 'AdManager');
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('Interstitial ad failed to show: ${error.message}', name: 'AdManager');
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
      onAdImpression: (ad) {
        developer.log('Interstitial ad impression', name: 'AdManager');
      },
    );
  }

  // Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      developer.log('Interstitial ad not ready, loading...', name: 'AdManager');
      loadInterstitialAd();
      return;
    }

    try {
      developer.log('Showing interstitial ad', name: 'AdManager');
      await _interstitialAd!.show();
    } catch (e) {
      developer.log('Error showing interstitial ad: $e', name: 'AdManager', error: e);
      _isInterstitialAdLoaded = false;
      loadInterstitialAd();
    }
  }

  // REWARDED AD METHODS
  Future<void> loadRewardedAd() async {
    if (_isLoadingAd || _isRewardedAdLoaded) {
      return;
    }

    try {
      _isLoadingAd = true;
      developer.log('Loading rewarded ad...', name: 'AdManager');

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _isLoadingAd = false;
            developer.log('Rewarded ad loaded successfully', name: 'AdManager');

            // Set up full-screen callbacks
            _setupRewardedAdCallbacks(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isRewardedAdLoaded = false;
            _isLoadingAd = false;
            developer.log('Rewarded ad failed to load: ${error.message}', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 60), loadRewardedAd);
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoaded = false;
      _isLoadingAd = false;
      developer.log('Error loading rewarded ad: $e', name: 'AdManager', error: e);

      // Retry after delay
      Future.delayed(const Duration(seconds: 60), loadRewardedAd);
    }
  }

  // Setup rewarded ad callbacks
  void _setupRewardedAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        developer.log('Rewarded ad showed full screen content', name: 'AdManager');
        _lastRewardedAdShown = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        developer.log('Rewarded ad dismissed', name: 'AdManager');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        developer.log('Rewarded ad failed to show: ${error.message}', name: 'AdManager');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
      onAdImpression: (ad) {
        developer.log('Rewarded ad impression', name: 'AdManager');
      },
    );
  }

  // Show rewarded ad with callback for reward
  Future<void> showRewardedAd(RewardCallback onRewarded) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      developer.log('Rewarded ad not ready, loading...', name: 'AdManager');
      await loadRewardedAd();

      if (!_isRewardedAdLoaded || _rewardedAd == null) {
        developer.log('Failed to load rewarded ad', name: 'AdManager');

        // In debug mode, simulate a reward for testing
        if (kDebugMode) {
          developer.log('DEBUG MODE: Simulating reward', name: 'AdManager');
          onRewarded(defaultRewardAmount);
        }
        return;
      }
    }

    try {
      developer.log('Showing rewarded ad', name: 'AdManager');
      await _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            final rewardAmount = reward.amount.toDouble();
            developer.log('User earned reward: $rewardAmount ${reward.type}', name: 'AdManager');
            onRewarded(rewardAmount);
          }
      );
    } catch (e) {
      developer.log('Error showing rewarded ad: $e', name: 'AdManager', error: e);
      _isRewardedAdLoaded = false;
      loadRewardedAd();

      // In debug mode, simulate a reward for testing failures
      if (kDebugMode) {
        developer.log('DEBUG MODE: Simulating reward after error', name: 'AdManager');
        onRewarded(defaultRewardAmount);
      }
    }
  }

  // Widget to display the countdown timer for next scheduled ad
  Widget getAdCountdownWidget() {
    return StreamBuilder<int>(
      stream: adCountdown,
      initialData: scheduledAdIntervalMinutes * 60,
      builder: (context, snapshot) {
        final seconds = snapshot.data ?? 0;

        // Only show when less than 60 seconds remain
        if (seconds > 60) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.infoColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                'Ad in ${seconds}s',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Public getters for ad status
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  // Clean up resources when no longer needed
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();

    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;

    _isRewardedAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isBannerAdLoaded = false;

    _scheduledAdTimer?.cancel();
    _adCountdownController.close();

    developer.log('AdManager resources disposed', name: 'AdManager');
  }
}