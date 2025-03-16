import 'package:equatable/equatable.dart';
import 'package:watch2earn/features/auth/models/auth_failure.dart';
import 'package:watch2earn/features/auth/models/user.dart';

class AuthState extends Equatable {
  final User? user;
  final bool isLoading;
  final AuthFailure? failure;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.failure,
    this.isAuthenticated = false,
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: true,
      isAuthenticated: false,
    );
  }

  factory AuthState.authenticated(User user) {
    return AuthState(
      user: user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthState.loading() {
    return const AuthState(
      isLoading: true,
    );
  }

  factory AuthState.error(AuthFailure failure) {
    return AuthState(
      failure: failure,
      isLoading: false,
      isAuthenticated: false,
    );
  }

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AuthFailure? failure,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      failure: failure ?? this.failure,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [user, isLoading, failure, isAuthenticated];
}
