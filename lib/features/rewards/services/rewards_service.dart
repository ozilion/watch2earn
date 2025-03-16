// lib/features/rewards/services/rewards_service.dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/auth/models/user.dart';
import 'package:watch2earn/features/auth/repositories/auth_repository.dart';
import 'package:watch2earn/features/rewards/models/reward_failure.dart';
import 'package:watch2earn/features/rewards/models/reward_history.dart';

abstract class RewardsService {
  Future<Either<RewardFailure, List<RewardHistory>>> getHistory(String userId);
  Future<Either<RewardFailure, User>> addReward(String userId, double amount);
}

class RewardsServiceImpl implements RewardsService {
  final FlutterSecureStorage _secureStorage;
  final AuthRepository _authRepository;
  final Dio _dio;

  // Anahtar adları
  static const String _rewardHistoryKey = 'reward_history';

  RewardsServiceImpl({
    required FlutterSecureStorage secureStorage,
    required AuthRepository authRepository,
    Dio? dio,
  })  : _secureStorage = secureStorage,
        _authRepository = authRepository,
        _dio = dio ?? Dio() {
    final backendUrl = AppConstants.backendBaseUrl;
    _dio.options.baseUrl = backendUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add logger
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => developer.log(object.toString(), name: 'RewardsService'),
    ));
  }

  @override
  Future<Either<RewardFailure, List<RewardHistory>>> getHistory(String userId) async {
    try {
      developer.log('Ödül geçmişi yerel depodan alınıyor: $userId için', name: 'RewardsService');

      // Yerel depodan ödül geçmişini al
      final historyJson = await _secureStorage.read(key: '${_rewardHistoryKey}_$userId');

      if (historyJson == null || historyJson.isEmpty) {
        developer.log('Ödül geçmişi bulunamadı, boş liste döndürülüyor', name: 'RewardsService');
        return const Right([]);
      }

      try {
        // JSON verisini ayrıştır
        final List<dynamic> historyList = jsonDecode(historyJson);

        // JSON ayrıştırma sürecini logla (debug için)
        if (kDebugMode) {
          developer.log('JSON ayrıştırılıyor: ${historyList.length} öğe', name: 'RewardsService');
          if (historyList.isNotEmpty) {
            developer.log('İlk öğe örneği: ${historyList.first}', name: 'RewardsService');
          }
        }

        // Güvenli ayrıştırıcı kullan
        final history = historyList.map((item) {
          try {
            return RewardHistory.fromJson(item);
          } catch (e) {
            developer.log('Tek öğe ayrıştırma hatası: $e - Öğe: $item',
                name: 'RewardsService', error: e);

            // Varsayılan bir öğe oluştur - hata atma
            return RewardHistory(
              id: item['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              userId: item['userId']?.toString() ?? userId,
              amount: _parseDouble(item['amount']),
              type: RewardType.other,
              createdAt: _parseDateTime(item['createdAt']),
              timestamp: _parseDateTime(item['timestamp']),
            );
          }
        }).toList();

        // En son eklenen en üstte olacak şekilde sırala
        history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        developer.log('${history.length} ödül geçmişi öğesi başarıyla yüklendi', name: 'RewardsService');
        return Right(history);
      } catch (e) {
        developer.log('Ödül geçmişi ayrıştırma hatası: $e', name: 'RewardsService', error: e);
        // Ayrıştırma hatası durumunda boş liste döndür
        return const Right([]);
      }
    } catch (e) {
      developer.log('Ödül geçmişini alma hatası: $e', name: 'RewardsService', error: e);
      return Right([]); // Hata durumunda boş liste döndür
    }
  }

  @override
  Future<Either<RewardFailure, User>> addReward(String userId, double amount) async {
    try {
      developer.log('$userId için $amount token ekleniyor', name: 'RewardsService');

      final token = await _secureStorage.read(key: AppConstants.authTokenKey);

      if (token == null) {
        developer.log('Kimlik doğrulama yapılmadı, ödül eklenemiyor', name: 'RewardsService');
        return Left(RewardFailure('Kimlik doğrulama yapılmadı'));
      }

      // Önce mevcut kullanıcıyı al
      final currentUserResult = await _authRepository.getCurrentUser();

      final currentUser = currentUserResult.fold(
            (failure) {
          developer.log('Mevcut kullanıcı alınamadı: ${failure.message}', name: 'RewardsService');
          throw Exception('Mevcut kullanıcı alınamadı');
        },
            (user) {
          if (user == null) {
            throw Exception('Kullanıcı bulunamadı');
          }
          return user;
        },
      );

      // Yeni bakiyeyi hesapla
      final newBalance = currentUser.tokenBalance + amount;
      developer.log('Mevcut bakiye: ${currentUser.tokenBalance}, eklenen: $amount, yeni bakiye: $newBalance',
          name: 'RewardsService');

      try {
        // Sunucuda bakiyeyi güncelle
        final response = await _dio.post(
          '/claim-reward',
          data: {
            'user_id': userId,
            'reward_amount': amount,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        // Sunucu güncellemesi başarılı
        if (response.statusCode == 200) {
          developer.log('Ödül sunucuya başarıyla eklendi', name: 'RewardsService');

          // Yanıttan kullanıcı güncellendi
          final updatedUser = _processServerResponse(response, currentUser, newBalance);

          // Ödül geçmişine ekle
          await _addRewardToHistory(userId, amount);

          return Right(updatedUser);
        } else {
          developer.log('Sunucu 200 olmayan durum kodu döndürdü: ${response.statusCode}', name: 'RewardsService');
          // Sunucu başarısız olursa yerel bakiyeyi güncelle
          return _updateLocalBalanceOnly(currentUser, amount);
        }
      } on DioException catch (e) {
        developer.log('Ödül eklerken DioException: ${e.message}', name: 'RewardsService', error: e);

        // API çağrısı başarısız olursa, sadece yerel bakiyeyi güncelle
        return _updateLocalBalanceOnly(currentUser, amount);
      }
    } catch (e) {
      developer.log('Ödül eklerken hata: $e', name: 'RewardsService', error: e);
      return Left(RewardFailure('Hata: ${e.toString()}'));
    }
  }

  // Sunucu yanıtını işleme
  User _processServerResponse(Response response, User currentUser, double newBalance) {
    try {
      // Yanıttan güncellenen kullanıcıyı ayrıştır
      final userData = response.data['user'] ?? response.data; // Farklı API yanıt formatlarını ele al

      // Yanıttan token bakiyesi varsa kullan
      double responseTokenBalance = 0.0;

      if (userData['token_balance'] != null) {
        responseTokenBalance = _parseDouble(userData['token_balance']);
        developer.log('Sunucudan token bakiyesi: $responseTokenBalance', name: 'RewardsService');
      }

      // Yanıt token bakiyesi içermiyorsa, hesaplanan değeri kullan
      final tokenBalance = responseTokenBalance > 0 ? responseTokenBalance : newBalance;

      // Yeni bakiye ile kullanıcıyı güncelle
      final updatedUser = currentUser.copyWith(
        tokenBalance: tokenBalance,
        updatedAt: DateTime.now(),
      );

      // Güncellenen kullanıcı verilerini yerel olarak kaydet
      _saveUpdatedUserData(updatedUser);

      return updatedUser;
    } catch (e) {
      developer.log('Yanıttan kullanıcı verilerini ayrıştırma hatası, hesaplanan bakiye kullanılıyor',
          name: 'RewardsService', error: e);

      // Ayrıştırma başarısız olursa, hesaplanan bakiyeyi kullan
      final updatedUser = currentUser.copyWith(
        tokenBalance: newBalance,
        updatedAt: DateTime.now(),
      );

      // Güncellenen kullanıcı verilerini yerel olarak kaydet
      _saveUpdatedUserData(updatedUser);

      return updatedUser;
    }
  }

  // Ödül geçmişine yeni bir öğe ekle
  Future<void> _addRewardToHistory(String userId, double amount) async {
    try {
      // Mevcut geçmişi al
      final result = await getHistory(userId);
      final historyList = result.fold(
            (failure) => <RewardHistory>[],
            (history) => List<RewardHistory>.from(history),
      );

      // Yeni ödül geçmişi öğesi oluştur
      final newReward = RewardHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Basit bir benzersiz kimlik oluştur
        userId: userId,
        amount: amount,
        type: RewardType.adReward, // Varsayılan tür
        createdAt: DateTime.now(),
        timestamp: DateTime.now(),
      );

      // Geçmiş listesinin başına ekle
      historyList.insert(0, newReward);

      // Geçmişi güncelle
      final historyJson = jsonEncode(historyList.map((e) => e.toJson()).toList());
      await _secureStorage.write(key: '${_rewardHistoryKey}_$userId', value: historyJson);

      developer.log('Ödül geçmişi yerel depoda güncellendi', name: 'RewardsService');
    } catch (e) {
      developer.log('Ödül geçmişini güncellerken hata: $e', name: 'RewardsService', error: e);
      // Geçmiş güncellenemese bile devam et, önemli bir hata değil
    }
  }

  // API başarısız olduğunda yerel bakiyeyi güncelle
  Future<Either<RewardFailure, User>> _updateLocalBalanceOnly(User currentUser, double amount) async {
    try {
      developer.log('Sadece yerel bakiye güncelleniyor', name: 'RewardsService');
      final newBalance = currentUser.tokenBalance + amount;

      final updatedUser = currentUser.copyWith(
        tokenBalance: newBalance,
        updatedAt: DateTime.now(),
      );

      // Güncellenen kullanıcı verilerini yerel olarak kaydet
      await _saveUpdatedUserData(updatedUser);

      // Ödül geçmişine ekle
      await _addRewardToHistory(currentUser.id, amount);

      developer.log('Yerel bakiye $newBalance olarak güncellendi', name: 'RewardsService');
      return Right(updatedUser);
    } catch (e) {
      developer.log('Yerel bakiyeyi güncellerken hata: $e', name: 'RewardsService', error: e);
      return Left(RewardFailure('Yerel bakiye güncellenirken hata: ${e.toString()}'));
    }
  }

  // Güncellenen kullanıcı verilerini kaydet
  Future<void> _saveUpdatedUserData(User user) async {
    try {
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(user.toJson()),
      );
      developer.log('Güncellenen kullanıcı verileri yerel olarak kaydedildi', name: 'RewardsService');
    } catch (e) {
      developer.log('Güncellenen kullanıcı verilerini kaydederken hata: $e', name: 'RewardsService', error: e);
    }
  }

  // Yardımcı metodlar
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      // Ayrıştırma hatası, varsayılan değer döndür
    }

    return DateTime.now();
  }
}