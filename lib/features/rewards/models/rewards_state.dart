// lib/features/rewards/models/rewards_state.dart
import 'package:equatable/equatable.dart';
import 'package:watch2earn/features/rewards/models/reward_history.dart';

class RewardsState extends Equatable {
  final List<RewardHistory> history;
  final bool isLoading;
  final bool isAdAvailable;
  final String? error;

  const RewardsState({
    required this.history,
    required this.isLoading,
    required this.isAdAvailable,
    this.error,
  });

  // Başlangıç durumu
  factory RewardsState.initial() {
    return const RewardsState(
      history: [],
      isLoading: false,
      isAdAvailable: false,
      error: null,
    );
  }

  // Yeni durum oluştur
  RewardsState copyWith({
    List<RewardHistory>? history,
    bool? isLoading,
    bool? isAdAvailable,
    String? error,
    bool clearError = false,
  }) {
    return RewardsState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isAdAvailable: isAdAvailable ?? this.isAdAvailable,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    history,
    isLoading,
    isAdAvailable,
    error,
  ];
}