// lib/features/auth/services/credentials_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsStorage {
  static const String _credentialsKey = 'saved_credentials';
  static const String _rememberMeKey = 'remember_me';
  final FlutterSecureStorage _secureStorage;

  CredentialsStorage({required FlutterSecureStorage secureStorage})
      : _secureStorage = secureStorage;

  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe
  }) async {
    if (rememberMe) {
      // Save credentials only if remember me is true
      final credentials = {
        'email': email,
        'password': password,
      };
      await _secureStorage.write(
        key: _credentialsKey,
        value: jsonEncode(credentials),
      );
    } else {
      // Clear stored credentials if remember me is false
      await _secureStorage.delete(key: _credentialsKey);
    }

    // Always save the remember me preference
    await _secureStorage.write(
      key: _rememberMeKey,
      value: rememberMe.toString(),
    );
  }

  Future<Map<String, dynamic>?> getSavedCredentials() async {
    final savedCredentialsJson = await _secureStorage.read(key: _credentialsKey);
    if (savedCredentialsJson == null || savedCredentialsJson.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(savedCredentialsJson) as Map<String, dynamic>;
    } catch (e) {
      // If there's an error in parsing, return null
      return null;
    }
  }

  Future<bool> getRememberMePreference() async {
    final savedPreference = await _secureStorage.read(key: _rememberMeKey);
    return savedPreference == 'true';
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _credentialsKey);
  }
}