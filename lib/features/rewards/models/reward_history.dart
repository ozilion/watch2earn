// lib/features/rewards/models/reward_history.dart
import 'package:flutter/foundation.dart';

enum RewardType {
  adReward,
  dailyLogin,
  levelUp,
  signupBonus,  // Ekledik
  watchMovie,   // Ekledik
  watchEpisode, // Ekledik
  earned,       // Ekledik
  other,
}

class RewardHistory {
  final String id;
  final String userId;
  final double amount;
  final RewardType type;
  final DateTime createdAt;
  final DateTime timestamp;

  const RewardHistory({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.timestamp,
  });

  factory RewardHistory.fromJson(Map<String, dynamic> json) {
    return RewardHistory(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      amount: _parseDouble(json['amount']),
      type: _parseRewardType(json['type']),
      createdAt: _parseDateTime(json['createdAt']),
      timestamp: _parseDateTime(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': describeEnum(type),
      'createdAt': createdAt.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Okunabilir tip adı (lokalizasyon anahtarı olarak da kullanılabilir)
  String get readableType {
    switch (type) {
      case RewardType.adReward:
        return 'Reklam İzleme Ödülü';
      case RewardType.dailyLogin:
        return 'Günlük Giriş Ödülü';
      case RewardType.levelUp:
        return 'Seviye Atlama Ödülü';
      case RewardType.signupBonus:
        return 'Kayıt Bonusu';
      case RewardType.watchMovie:
        return 'Film İzleme Ödülü';
      case RewardType.watchEpisode:
        return 'Dizi Bölümü İzleme Ödülü';
      case RewardType.earned:
        return 'Kazanılan Ödül';
      case RewardType.other:
        return 'Token Ödülü';
    }
  }

  // Helper function for enum conversion
  static String describeEnum(Object enumValue) {
    final String description = enumValue.toString();
    final int indexOfDot = description.indexOf('.');
    assert(indexOfDot != -1 && indexOfDot < description.length - 1);
    return description.substring(indexOfDot + 1);
  }

  // Parse double safely
  static double _parseDouble(dynamic value) {
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

  // Parse DateTime safely
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      if (value is String) {
        return DateTime.parse(value);
      }
    } catch (e) {
      // Handle parsing error
    }

    return DateTime.now();
  }

  // Parse RewardType safely
  static RewardType _parseRewardType(dynamic value) {
    if (value == null) return RewardType.other;

    if (value is String) {
      try {
        return RewardType.values.firstWhere(
              (e) => describeEnum(e) == value,
          orElse: () => RewardType.other,
        );
      } catch (e) {
        return RewardType.other;
      }
    }

    return RewardType.other;
  }
}