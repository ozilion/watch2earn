import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:watch2earn/features/auth/models/auth_failure.dart';
import 'package:watch2earn/features/auth/models/auth_state.dart';
import 'package:watch2earn/features/auth/models/user.dart';
import 'package:watch2earn/features/auth/repositories/auth_repository.dart';

// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthRepositoryImpl(
    secureStorage: secureStorage,
  );
});

// Provider for auth state to maintain compatibility with existing code
final authStateProvider = StateProvider<AuthState?>((ref) => null);

// Auth controller notifier
class AuthController extends AsyncNotifier<AuthState> {
  late StreamController<AuthState> _streamController;

  // Expose a stream of auth state changes for GoRouter to listen to
  Stream<AuthState> get stream => _streamController.stream;

  // Convenience getters
  User? get currentUser => state.valueOrNull?.user;
  bool get isAuthenticated => state.valueOrNull?.isAuthenticated ?? false;

  @override
  Future<AuthState> build() async {
    // Initialize the stream controller
    _streamController = StreamController<AuthState>.broadcast();

    // Register cleanup when this notifier is disposed
    ref.onDispose(() {
      developer.log('Closing auth state stream', name: 'AuthController');
      _streamController.close();
    });

    developer.log('Building AuthController', name: 'AuthController');

    // Initialize auth state
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.getCurrentUser();

    // Return initial state based on repository response
    return result.fold(
          (failure) {
        developer.log('Failed to get current user: ${failure.message}', name: 'AuthController');
        final state = AuthState(isAuthenticated: false, user: null, failure: failure);
        _streamController.add(state);
        return state;
      },
          (user) {
        final isAuthenticated = user != null;
        developer.log('Current user retrieved: ${user?.name}, isAuthenticated=$isAuthenticated', name: 'AuthController');
        final state = AuthState(isAuthenticated: isAuthenticated, user: user, failure: null);
        _streamController.add(state);
        return state;
      },
    );
  }

  // Login method
  Future<void> login(String email, String password) async {
    developer.log('Login attempt for email: $email', name: 'AuthController');

    // Set loading state
    state = const AsyncLoading();

    // Attempt login
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.login(email, password);

    // Update state based on result
    state = await result.fold(
          (failure) async {
        developer.log('Login failed: ${failure.message}', name: 'AuthController');
        final newState = AuthState(isAuthenticated: false, user: null, failure: failure);
        _streamController.add(newState);
        return AsyncData(newState);
      },
          (user) async {
        developer.log('Login successful for user: ${user.name}', name: 'AuthController');
        final newState = AuthState(isAuthenticated: true, user: user, failure: null);
        _streamController.add(newState);
        return AsyncData(newState);
      },
    );

    // Update the authStateProvider for components that use it directly
    ref.read(authStateProvider.notifier).state = state.value;
  }

  // Register method
  Future<void> register(String name, String email, String password) async {
    developer.log('Registration attempt for email: $email', name: 'AuthController');

    // Set loading state
    state = const AsyncLoading();

    // Attempt registration
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.register(name, email, password);

    // Update state based on result
    state = await result.fold(
          (failure) async {
        developer.log('Registration failed: ${failure.message}', name: 'AuthController');
        final newState = AuthState(isAuthenticated: false, user: null, failure: failure);
        _streamController.add(newState);
        return AsyncData(newState);
      },
          (user) async {
        developer.log('Registration successful for user: ${user.name}', name: 'AuthController');
        final newState = AuthState(isAuthenticated: true, user: user, failure: null);
        _streamController.add(newState);
        return AsyncData(newState);
      },
    );

    // Update the authStateProvider for components that use it directly
    ref.read(authStateProvider.notifier).state = state.value;
  }

  // Logout method
  Future<void> logout() async {
    developer.log('Logout attempt', name: 'AuthController');

    // Set loading state
    state = const AsyncLoading();

    // Attempt logout
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.logout();

    // Update state based on result
    state = await result.fold(
          (failure) async {
        developer.log('Logout failed: ${failure.message}', name: 'AuthController');
        // Even if logout fails on the server, we should consider the user logged out locally
        final newState = AuthState(isAuthenticated: false, user: null, failure: failure);
        _streamController.add(newState);
        return AsyncData(newState);
      },
          (success) async {
        developer.log('Logout successful', name: 'AuthController');
        final newState = AuthState(isAuthenticated: false, user: null, failure: null);
        _streamController.add(newState);
        return AsyncData(newState);
      },
    );

    // Update the authStateProvider for components that use it directly
    ref.read(authStateProvider.notifier).state = state.value;
  }

  // Update token balance
  Future<void> updateTokenBalance(double newBalance) async {
    developer.log('Updating token balance to: $newBalance', name: 'AuthController');

    if (state.value == null || state.value!.user == null) {
      developer.log('Cannot update balance: User not logged in', name: 'AuthController');
      return;
    }

    // Set loading state
    state = const AsyncLoading();

    // Attempt to update token balance
    final repository = ref.read(authRepositoryProvider);
    final result = await repository.updateUserTokenBalance(newBalance);

    // Update state based on result
    state = await result.fold(
          (failure) async {
        developer.log('Token balance update failed: ${failure.message}', name: 'AuthController');
        // Preserve the previous state but add the failure
        final previousState = state.value!;
        final newState = AuthState(
          isAuthenticated: previousState.isAuthenticated,
          user: previousState.user,
          failure: failure,
        );
        _streamController.add(newState);
        return AsyncData(newState);
      },
          (updatedUser) async {
        developer.log('Token balance updated successfully to: ${updatedUser.tokenBalance}', name: 'AuthController');
        final newState = AuthState(
          isAuthenticated: true,
          user: updatedUser,
          failure: null,
        );
        _streamController.add(newState);
        return AsyncData(newState);
      },
    );

    // Update the authStateProvider for components that use it directly
    ref.read(authStateProvider.notifier).state = state.value;
  }

  // New method to directly update user data (used by RewardsController)
  Future<void> updateUserData(User updatedUser) async {
    developer.log('Directly updating user data for: ${updatedUser.name}, new balance: ${updatedUser.tokenBalance}',
        name: 'AuthController');

    if (state.value == null) {
      developer.log('Cannot update user data: AuthState is null', name: 'AuthController');
      return;
    }

    // Create new state with updated user
    final newState = AuthState(
      isAuthenticated: true,
      user: updatedUser,
      failure: null,
    );

    // Update state
    state = AsyncData(newState);

    // Broadcast state change
    _streamController.add(newState);

    // Update the authStateProvider for components that use it directly
    ref.read(authStateProvider.notifier).state = newState;

    developer.log('User data successfully updated throughout the app', name: 'AuthController');
  }
}

// Provider for the auth controller
final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});