// lib/features/rewards/services/ad_manager.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/core/theme/text_styles.dart';

typedef RewardCallback = Function(double rewardAmount);

class AdManager {
  // Ad state tracking
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isLoading = false;

  // Timer for scheduled ads
  Timer? _scheduledAdTimer;

  // Stream controller for ad countdown
  final _adCountdownController = BehaviorSubject<int>();
  Stream<int> get adCountdown => _adCountdownController.stream;

  // Constants for ad display frequency
  static const int rewardedAdIntervalMinutes = 10; // How often to show rewarded ads
  static const int interactionCountBeforeAd = 3; // Show ad after this many content interactions

  // Track user interactions
  int _itemInteractionCount = 0;

  // Ad units defined safely
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

  DateTime? _lastRewardedAdShown;

  // Get ad unit ID safely
  static String _getSafeAdUnitId(String key, String defaultValue) {
    try {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        developer.log('$key için geçerli bir değer bulunamadı, varsayılan kullanılıyor', name: 'AdManager');
        return defaultValue;
      }
      return value;
    } catch (e) {
      developer.log('$key alınırken hata: $e, varsayılan kullanılıyor', name: 'AdManager');
      return defaultValue;
    }
  }

  AdManager() {
    _initializeAds();
    _startScheduledAdTimer();
  }

  // Initialize ads
  Future<void> _initializeAds() async {
    try {
      developer.log('MobileAds initialization başlatılıyor...', name: 'AdManager');

      // Initialize SDK
      final initStatus = await MobileAds.instance.initialize();

      // Log SDK status
      final statusMap = <String, String>{};
      initStatus.adapterStatuses.forEach((key, value) {
        statusMap[key] = '${value.state.name} - ${value.description}';
      });

      developer.log('AdMob başlatma durumu: $statusMap', name: 'AdManager');

      // Configure test devices
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
          testDeviceIds: [
            'EMULATOR', // For emulators
          ],
        ),
      );

      developer.log('Google Mobile Ads SDK başarıyla başlatıldı', name: 'AdManager');

      // Log ad unit IDs
      developer.log('Banner ad ID: $_bannerAdUnitId', name: 'AdManager');
      developer.log('Interstitial ad ID: $_interstitialAdUnitId', name: 'AdManager');
      developer.log('Rewarded ad ID: $_rewardedAdUnitId', name: 'AdManager');

      // Load ads
      await loadRewardedAd();
      await loadInterstitialAd();
      await loadBannerAd();
    } catch (e) {
      developer.log('Ads initialization error: $e', name: 'AdManager', error: e);
    }
  }

  // Rewarded ad methods
  Future<void> loadRewardedAd() async {
    if (_isLoading) {
      developer.log('Ödüllü reklam zaten yükleniyor', name: 'AdManager');
      return;
    }

    try {
      _isLoading = true;
      developer.log('Ödüllü reklam yükleniyor... ID: $_rewardedAdUnitId', name: 'AdManager');

      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isRewardedAdLoaded = true;
            _isLoading = false;
            developer.log('Ödüllü reklam başarıyla yüklendi', name: 'AdManager');

            // Set full screen content callbacks
            _setRewardedAdCallbacks();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isRewardedAdLoaded = false;
            _isLoading = false;
            developer.log('Ödüllü reklam yüklenirken hata: Kod: ${error.code}, Mesaj: ${error.message}, Domain: ${error.domain}', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 30), () {
              loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      developer.log('Ödüllü reklam yüklenirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isRewardedAdLoaded = false;
      _isLoading = false;

      // Retry after error
      Future.delayed(const Duration(seconds: 30), () {
        loadRewardedAd();
      });
    }
  }

  void _setRewardedAdCallbacks() {
    if (_rewardedAd == null) return;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        developer.log('Ödüllü reklam tam ekran gösterildi', name: 'AdManager');
        _lastRewardedAdShown = DateTime.now();
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        developer.log('Ödüllü reklam kapatıldı', name: 'AdManager');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        developer.log('Ödüllü reklam gösterilirken hata: $error', name: 'AdManager');
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
      },
    );
  }

  Future<void> showRewardedAd(RewardCallback onRewarded) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      developer.log('Ödüllü reklam henüz hazır değil, yükleniyor...', name: 'AdManager');
      await loadRewardedAd();

      if (!_isRewardedAdLoaded || _rewardedAd == null) {
        developer.log('Ödüllü reklam gösterilemiyor, yükleme başarısız', name: 'AdManager');

        // Simulation mode for failed ads (only in debug mode)
        if (kDebugMode) {
          developer.log('DEBUG MODU: Benzetim ödülü veriliyor', name: 'AdManager');
          onRewarded(15.0); // Default reward for testing
        }
        return;
      }
    }

    try {
      developer.log('Ödüllü reklam gösteriliyor...', name: 'AdManager');
      await _rewardedAd!.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            // Pass the reward amount to the callback
            double rewardAmount = reward.amount.toDouble();
            developer.log('Kullanıcı ödülü kazandı: $rewardAmount ${reward.type}', name: 'AdManager');
            onRewarded(rewardAmount);
          }
      );
    } catch (e) {
      developer.log('Ödüllü reklam gösterilirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isRewardedAdLoaded = false;
      loadRewardedAd();

      // Simulation mode for errors (only in debug mode)
      if (kDebugMode) {
        developer.log('DEBUG MODU: Benzetim ödülü veriliyor (hata sonrası)', name: 'AdManager');
        onRewarded(15.0); // Default reward for testing
      }
    }
  }

  // Interstitial ad methods
  Future<void> loadInterstitialAd() async {
    if (_isLoading) {
      developer.log('Geçiş reklamı zaten yükleniyor', name: 'AdManager');
      return;
    }

    try {
      _isLoading = true;
      developer.log('Geçiş reklamı yükleniyor... ID: $_interstitialAdUnitId', name: 'AdManager');

      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
            _isLoading = false;
            developer.log('Geçiş reklamı başarıyla yüklendi', name: 'AdManager');

            // Set full screen content callbacks
            _setInterstitialAdCallbacks();
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialAdLoaded = false;
            _isLoading = false;
            developer.log('Geçiş reklamı yüklenirken hata: Kod: ${error.code}, Mesaj: ${error.message}', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 30), () {
              loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      developer.log('Geçiş reklamı yüklenirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isInterstitialAdLoaded = false;
      _isLoading = false;

      // Retry after error
      Future.delayed(const Duration(seconds: 30), () {
        loadInterstitialAd();
      });
    }
  }

  void _setInterstitialAdCallbacks() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        developer.log('Geçiş reklamı tam ekran gösterildi', name: 'AdManager');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        developer.log('Geçiş reklamı kapatıldı', name: 'AdManager');
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        developer.log('Geçiş reklamı gösterilirken hata: $error', name: 'AdManager');
        ad.dispose();
        _isInterstitialAdLoaded = false;
        loadInterstitialAd();
      },
    );
  }

  Future<void> showInterstitialAd() async {
    if (!_isInterstitialAdLoaded || _interstitialAd == null) {
      developer.log('Geçiş reklamı henüz hazır değil, yükleniyor...', name: 'AdManager');
      await loadInterstitialAd();

      if (!_isInterstitialAdLoaded || _interstitialAd == null) {
        developer.log('Geçiş reklamı gösterilemiyor, yükleme başarısız', name: 'AdManager');
        return;
      }
    }

    try {
      developer.log('Geçiş reklamı gösteriliyor...', name: 'AdManager');
      await _interstitialAd!.show();
    } catch (e) {
      developer.log('Geçiş reklamı gösterilirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isInterstitialAdLoaded = false;
      loadInterstitialAd();
    }
  }

  // Banner ad methods
  Future<void> loadBannerAd() async {
    if (_isLoading) {
      developer.log('Banner reklam zaten yükleniyor', name: 'AdManager');
      return;
    }

    try {
      _isLoading = true;
      developer.log('Banner reklam yükleniyor... ID: $_bannerAdUnitId', name: 'AdManager');

      _bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerAdLoaded = true;
            _isLoading = false;
            developer.log('Banner reklam başarıyla yüklendi', name: 'AdManager');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _isBannerAdLoaded = false;
            _isLoading = false;
            developer.log('Banner reklam yüklenirken hata: $error', name: 'AdManager');

            // Retry after delay
            Future.delayed(const Duration(seconds: 30), () {
              loadBannerAd();
            });
          },
          onAdOpened: (ad) {
            developer.log('Banner reklam açıldı', name: 'AdManager');
          },
          onAdClosed: (ad) {
            developer.log('Banner reklam kapatıldı', name: 'AdManager');
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      developer.log('Banner reklam yüklenirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isBannerAdLoaded = false;
      _isLoading = false;

      // Retry after error
      Future.delayed(const Duration(seconds: 30), () {
        loadBannerAd();
      });
    }
  }

  // Get a widget representing the banner ad
  Widget getBannerAd() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      // Request loading if not ready
      if (!_isLoading) {
        loadBannerAd();
      }

      // Return placeholder
      return Container(
        height: 50,
        color: Colors.transparent,
        child: const Center(
          child: Text('Advertisement', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  // Start the scheduled ad timer
  void _startScheduledAdTimer() {
    // Cancel existing timer if any
    _scheduledAdTimer?.cancel();

    // Start countdown for scheduled ad
    _adCountdownController.add(rewardedAdIntervalMinutes * 60);

    // Create a timer to decrease the countdown
    _scheduledAdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_adCountdownController.isClosed) {
        timer.cancel();
        return;
      }

      final currentValue = _adCountdownController.value;
      if (currentValue <= 0) {
        // Time to show an ad
        _adCountdownController.add(rewardedAdIntervalMinutes * 60);

        // Check if we can show an ad (not recently shown)
        final canShowAd = _lastRewardedAdShown == null ||
            DateTime.now().difference(_lastRewardedAdShown!).inMinutes >= 1;

        if (canShowAd && _isRewardedAdLoaded) {
          // Add a small delay to avoid immediate ad display
          Future.delayed(const Duration(seconds: 1), () {
            showRewardedAd((reward) {
              // Ad shown, no direct reward since this is a scheduled ad
              developer.log('Scheduled ad shown', name: 'AdManager');
            });
          });
        }
      } else {
        _adCountdownController.add(currentValue - 1);
      }
    });
  }

  // Track content interactions and show ad after certain number
  void trackContentInteraction() {
    _itemInteractionCount++;

    if (_itemInteractionCount >= interactionCountBeforeAd) {
      _itemInteractionCount = 0;

      // Show interstitial ad after delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_isInterstitialAdLoaded) {
          showInterstitialAd();
        }
      });
    }
  }

  // Widget to display the ad countdown
  Widget getAdCountdownWidget() {
    return StreamBuilder<int>(
      stream: adCountdown,
      initialData: rewardedAdIntervalMinutes * 60,
      builder: (context, snapshot) {
        final seconds = snapshot.data ?? 0;

        // Only show when less than 60 seconds remain
        if (seconds > 60) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.infoColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.av_timer, color: Colors.white, size: 16),
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

  // Status getters
  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();

    _rewardedAd = null;
    _interstitialAd = null;
    _bannerAd = null;

    _isRewardedAdLoaded = false;
    _isInterstitialAdLoaded = false;
    _isBannerAdLoaded = false;

    _scheduledAdTimer?.cancel();
    _adCountdownController.close();

    developer.log('AdManager kaynakları temizlendi', name: 'AdManager');
  }
}