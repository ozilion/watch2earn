import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final double tokenBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.tokenBalance = 0.0,
    this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    double? tokenBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      tokenBalance: (json['token_balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token_balance': tokenBalance,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        tokenBalance,
        createdAt,
        updatedAt,
        profileImageUrl,
      ];
}
