// lib/features/rewards/controllers/rewards_controller.dart
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
    developer.log('RewardsController başlatılıyor', name: 'RewardsController');

    // Başlangıç durumu
    state = AsyncValue.data(RewardsState.initial());

    try {
      // İlk reklam yüklemesi
      await _adManager.loadRewardedAd();

      // Reklam durumunu güncelle
      final isAdAvailable = _adManager.isRewardedAdLoaded;

      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isAdAvailable: isAdAvailable,
      ) ??
          RewardsState.initial().copyWith(
            isAdAvailable: isAdAvailable,
          ));

      developer.log(
          'RewardsController başlatma tamamlandı, reklam durumu: $isAdAvailable',
          name: 'RewardsController');
    } catch (e) {
      developer.log('RewardsController başlatma hatası: $e',
          name: 'RewardsController', error: e);
      // Hataya rağmen devam et, uygulamanın çalışmasını engellemeyecek
    }
  }

  Future<void> loadRewardHistory(String userId) async {
    developer.log('$userId kullanıcısı için ödül geçmişi yükleniyor',
        name: 'RewardsController');

    // Geçmişi koruyarak yükleme durumunu ayarla
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
          developer.log('Ödül geçmişi yüklenemedi: ${failure.message}',
              name: 'RewardsController');
          // Geçmiş yükleme hataları için hata durumu ayarlamıyoruz - sadece mevcut geçmişi koruyoruz
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
          developer.log(
              '${history.length} ödül geçmişi öğesi başarıyla yüklendi',
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
      developer.log('loadRewardHistory içinde istisna: $e',
          name: 'RewardsController', error: e);
      // Geçmiş yükleme hataları için hata durumu ayarlamıyoruz - sadece mevcut geçmişi koruyoruz
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

    // Reklam durumunu kontrol et ve güncelle
    _checkAdStatus();
  }

  Future<void> watchRewardedAd(String userId) async {
    developer.log('$userId kullanıcısı için ödüllü reklam akışı başlatılıyor',
        name: 'RewardsController');

    // Geçmişi koruyarak yükleme durumunu ayarla
    final currentHistory = state.valueOrNull?.history ?? [];

    state = AsyncValue.data(state.valueOrNull?.copyWith(
      isLoading: true,
      isAdAvailable: false, // Reklam gösterimi sırasında kullanılamaz
      clearError: true,
    ) ??
        RewardsState.initial().copyWith(
          isLoading: true,
          history: currentHistory,
          isAdAvailable: false,
        ));

    try {
      // Reklam göster ve ödülü işle
      await _adManager.showRewardedAd((rewardAmount) async {
        developer.log('Reklam tamamlandı, $rewardAmount token ödülü ekleniyor',
            name: 'RewardsController');

        try {
          // Kullanıcı bakiyesine ödül ekle
          final result = await _rewardsService.addReward(userId, rewardAmount);

          result.fold(
                (failure) {
              developer.log('Ödül eklenemedi: ${failure.message}',
                  name: 'RewardsController');
              // Hatayı göster ama çökmeyi engelle
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
              developer.log(
                  'Ödül başarıyla eklendi, yeni bakiye: ${newUser.tokenBalance}',
                  name: 'RewardsController');

              // Auth kontrolcüsünde kullanıcı verilerini güncelle
              await _authController.updateUserData(newUser);
              developer.log('Auth kontrolcüsünde kullanıcı verileri güncellendi',
                  name: 'RewardsController');

              // Ödül geçmişini yenile
              loadRewardHistory(userId);
            },
          );
        } catch (e) {
          developer.log('Ödülü işlerken istisna: $e',
              name: 'RewardsController', error: e);
          // Hatayı göster ama çökmeyi engelle
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
      developer.log('watchRewardedAd içinde istisna: $e',
          name: 'RewardsController', error: e);
      // Hatayı göster
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
      // Her durumda yükleme durumunu sıfırla
      if (mounted) {
        state = AsyncValue.data(state.valueOrNull?.copyWith(
          isLoading: false,
        ) ??
            RewardsState.initial().copyWith(
              isLoading: false,
              history: currentHistory,
            ));
      }

      // Reklam durumunu kontrol et ve güncelle
      _checkAdStatus();
    }
  }

  // Reklam durumunu kontrol et ve güncelle
  void _checkAdStatus() {
    final isAdAvailable = _adManager.isRewardedAdLoaded;

    // Eğer durum değiştiyse güncelle
    if (state.valueOrNull?.isAdAvailable != isAdAvailable) {
      state = AsyncValue.data(state.valueOrNull?.copyWith(
        isAdAvailable: isAdAvailable,
      ) ??
          RewardsState.initial().copyWith(
            isAdAvailable: isAdAvailable,
          ));

      developer.log('Reklam durumu güncellendi: $isAdAvailable',
          name: 'RewardsController');
    }

    // Eğer reklam yüklü değilse, yüklemeyi dene
    if (!isAdAvailable) {
      _adManager.loadRewardedAd();
    }
  }

  @override
  void dispose() {
    try {
      _adManager.dispose();
    } catch (e) {
      developer.log('AdManager temizlenirken hata: $e',
          name: 'RewardsController', error: e);
    }
    super.dispose();
  }
}