// lib/features/rewards/services/ad_manager.dart
import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

typedef RewardCallback = Function(double rewardAmount);

class AdManager {
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _isLoading = false;

  // Ad units tanımlarını güvenli bir şekilde al
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

  // Dotenv'den güvenli şekilde ad unit ID'sini al
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
  }

  // Reklamları başlat
  Future<void> _initializeAds() async {
    try {
      developer.log('MobileAds initialization başlatılıyor...', name: 'AdManager');

      // SDK'nın durumunu kontrol et
      final initStatus = await MobileAds.instance.initialize();

      // SDK durumunu logla
      final statusMap = <String, String>{};
      initStatus.adapterStatuses.forEach((key, value) {
        statusMap[key] = '${value.state.name} - ${value.description}';
      });

      developer.log('AdMob başlatma durumu: $statusMap', name: 'AdManager');

      // Test cihazları yapılandırması
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
          testDeviceIds: [
            'EMULATOR', // Emülatörler için
          ],
        ),
      );

      developer.log('Google Mobile Ads SDK başarıyla başlatıldı', name: 'AdManager');

      // ID'leri logla
      developer.log('Banner ad ID: $_bannerAdUnitId', name: 'AdManager');
      developer.log('Interstitial ad ID: $_interstitialAdUnitId', name: 'AdManager');
      developer.log('Rewarded ad ID: $_rewardedAdUnitId', name: 'AdManager');

      // Reklamları yükle
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

            // Belirli bir süre sonra tekrar dene
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

      // Hatadan sonra tekrar dene
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

        // Reklam yüklenemediğinde benzetim modu - varsayılan ödül (sadece debug modunda)
        if (kDebugMode) {
          developer.log('DEBUG MODU: Benzetim ödülü veriliyor', name: 'AdManager');
          onRewarded(15.0); // Test için varsayılan ödül
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

      // Hata durumunda benzetim modu - varsayılan ödül (sadece debug modunda)
      if (kDebugMode) {
        developer.log('DEBUG MODU: Benzetim ödülü veriliyor (hata sonrası)', name: 'AdManager');
        onRewarded(15.0); // Test için varsayılan ödül
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

            // Belirli bir süre sonra tekrar dene
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

      // Hatadan sonra tekrar dene
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

            // Belirli bir süre sonra tekrar dene
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

      // Hatadan sonra tekrar dene
      Future.delayed(const Duration(seconds: 30), () {
        loadBannerAd();
      });
    }
  }

  // Get a widget representing the banner ad
  Widget getBannerAd() {
    if (!_isBannerAdLoaded || _bannerAd == null) {
      developer.log('Banner reklam henüz yüklenmedi, yükleniyor...', name: 'AdManager');
      loadBannerAd();
      return Container(
        height: 50,
        color: Colors.grey[300],
        child: const Center(
          child: Text('Reklam yükleniyor...'),
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

  // Farklı banner boyutları için ek metodlar
  Future<BannerAd?> loadBannerWithSize(AdSize adSize) async {
    if (_isLoading) {
      developer.log('Özel boyutlu banner reklam zaten yükleniyor', name: 'AdManager');
      return null;
    }

    try {
      _isLoading = true;
      developer.log('Özel boyutlu banner reklam yükleniyor...', name: 'AdManager');

      final bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isLoading = false;
            developer.log('Özel boyutlu banner reklam başarıyla yüklendi', name: 'AdManager');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            _isLoading = false;
            developer.log('Özel boyutlu banner reklam yüklenirken hata: $error', name: 'AdManager');
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      developer.log('Özel boyutlu banner reklam yüklenirken beklenmeyen hata: $e', name: 'AdManager', error: e);
      _isLoading = false;
      return null;
    }
  }

  Widget getBannerAdWithSize(AdSize adSize) {
    return FutureBuilder<BannerAd?>(
      future: loadBannerWithSize(adSize),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: adSize.height.toDouble(),
            color: Colors.grey[300],
            child: const Center(
              child: Text('Reklam yükleniyor...'),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            height: adSize.height.toDouble(),
            color: Colors.grey[300],
            child: const Center(
              child: Text('Reklam yüklenemedi'),
            ),
          );
        }

        return Container(
          alignment: Alignment.center,
          width: snapshot.data!.size.width.toDouble(),
          height: snapshot.data!.size.height.toDouble(),
          child: AdWidget(ad: snapshot.data!),
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

    developer.log('AdManager kaynakları temizlendi', name: 'AdManager');
  }
}