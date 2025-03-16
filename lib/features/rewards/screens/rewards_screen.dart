import 'dart:developer' as developer;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watch2earn/core/theme/app_colors.dart';
import 'package:watch2earn/features/auth/providers/auth_provider.dart';
import 'package:watch2earn/features/rewards/providers/rewards_provider.dart';
import 'package:watch2earn/features/rewards/widgets/reward_history_item.dart';
import 'package:watch2earn/features/rewards/widgets/rewards_balance_card.dart';
import 'package:watch2earn/shared/widgets/error_view.dart';
import 'package:watch2earn/shared/widgets/loading_view.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  @override
  void initState() {
    super.initState();
    developer.log('RewardsScreen başlatıldı', name: 'RewardsScreen');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRewardHistory();
    });
  }

  void _loadRewardHistory() {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user != null) {
      developer.log('${user.id} kullanıcısı için ödül geçmişi yükleniyor, mevcut bakiye: ${user.tokenBalance}',
          name: 'RewardsScreen');
      ref.read(rewardsControllerProvider.notifier).loadRewardHistory(user.id);
    } else {
      developer.log('Ödül geçmişi yüklenemiyor - kullanıcı null', name: 'RewardsScreen');
    }
  }

  void _onWatchAdPressed() async {
    final user = ref.read(authControllerProvider).valueOrNull?.user;
    if (user != null) {
      developer.log('${user.id} kullanıcısı için reklam izleme düğmesine basıldı', name: 'RewardsScreen');

      // Reklam izleme işlemi başlatıldığında bir SnackBar göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('tokens.watching_ad'.tr()),
          duration: const Duration(seconds: 1),
        ),
      );

      // Reklam izleme işlemini başlat
      await ref.read(rewardsControllerProvider.notifier).watchRewardedAd(user.id);

      // İşlem tamamlandıktan sonra
      developer.log('Ödüllü reklam akışı tamamlandı', name: 'RewardsScreen');
    } else {
      developer.log('Reklam izlenemiyor - kullanıcı null', name: 'RewardsScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth durumunu izleyerek token bakiyesi değiştiğinde yeniden oluştur
    final authState = ref.watch(authControllerProvider);
    final user = authState.valueOrNull?.user;
    final rewardsState = ref.watch(rewardsControllerProvider);

    // Güncellenmiş verilerle oluşturma
    if (authState.hasValue && user != null) {
      developer.log('RewardsScreen, kullanıcı token bakiyesiyle oluşturuluyor: ${user.tokenBalance}',
          name: 'RewardsScreen');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('tokens.earn'.tr()),
        actions: [
          // Yenileme düğmesi
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRewardHistory,
            tooltip: 'Verileri yenile',
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text('tokens.please_login'.tr()))
          : rewardsState.when(
        data: (state) {
          // Reklam kullanılabilirliğini kontrol et
          final isAdAvailable = state.isAdAvailable;

          return Column(
            children: [
              RewardsBalanceCard(
                balance: user.tokenBalance, // Auth durumundan bakiyeyi kullan
                onWatchAdPressed: isAdAvailable ? _onWatchAdPressed : null, // Reklam yoksa devre dışı bırak
                isWatchingAd: state.isLoading,
              ),

              // Reklam kullanılamıyorsa bilgi mesajı göster
              if (!isAdAvailable && !state.isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'tokens.ad_not_available'.tr(),
                    style: TextStyle(color: Colors.orange[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Hata varsa göster
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state.error!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 16),

              // Geçmiş başlığı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'tokens.history'.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (state.history.isNotEmpty)
                      Text(
                        '${state.history.length} ${state.history.length == 1 ? "tokens.entry".tr() : "tokens.entries".tr()}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Geçmiş listesi
              Expanded(
                child: state.history.isEmpty
                    ? Center(
                  child: Text(
                    'tokens.token_history_empty'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  itemCount: state.history.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return RewardHistoryItem(
                      reward: state.history[index],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (error, stackTrace) {
          developer.log('RewardsScreen\'de hata: $error', name: 'RewardsScreen', error: error, stackTrace: stackTrace);
          return ErrorView(
            message: error.toString(),
            onRetry: _loadRewardHistory,
          );
        },
      ),
    );
  }
}