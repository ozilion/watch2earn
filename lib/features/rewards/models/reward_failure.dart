// File: lib/features/rewards/models/reward_failure.dart

/// Represents a failure that occurred during reward operations
class RewardFailure {
  final String message;

  const RewardFailure(this.message);

  @override
  String toString() => message;
}