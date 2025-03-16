import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:watch2earn/core/constants/app_constants.dart';
import 'package:watch2earn/features/auth/models/auth_failure.dart';
import 'package:watch2earn/features/auth/models/user.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, User>> login(String email, String password);
  Future<Either<AuthFailure, User>> register(String name, String email, String password);
  Future<Either<AuthFailure, bool>> logout();
  Future<Either<AuthFailure, User?>> getCurrentUser();
  Future<Either<AuthFailure, User>> updateUserTokenBalance(double newBalance);
}

class AuthRepositoryImpl implements AuthRepository {
  final FlutterSecureStorage secureStorage;
  final Dio _dio;

  AuthRepositoryImpl({
    required this.secureStorage,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    final backendUrl = dotenv.env['BACKEND_API_URL'] ?? AppConstants.backendBaseUrl;
    _dio.options.baseUrl = backendUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Add interceptor for logging requests and responses
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => developer.log(object.toString(), name: 'DioAPI'),
    ));
  }

  // Helper method to safely parse user ID which could be int or string from API
  String _parseUserId(dynamic id) {
    if (id == null) {
      throw FormatException('User ID is null');
    }

    // If id is already a string, return it
    if (id is String) {
      return id;
    }

    // If id is an int, convert to string
    if (id is int) {
      return id.toString();
    }

    // Handle any other unexpected types
    throw FormatException('Invalid user ID format: $id (${id.runtimeType})');
  }

  // Helper method to safely parse DateTime
  DateTime? _parseDateTime(dynamic dateString) {
    if (dateString == null) {
      return null;
    }

    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      developer.log('Error parsing date: $dateString', name: 'AuthRepository', error: e);
      return null;
    }
  }

  // Helper method to parse token balance
  double _parseTokenBalance(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        developer.log('Error parsing token balance: $value', name: 'AuthRepository', error: e);
        return 0.0;
      }
    }

    return 0.0;
  }

  // Helper to save user data to secure storage
  Future<void> _saveUserData(User user, String? token) async {
    try {
      // Save user data
      await secureStorage.write(
        key: 'user_data',
        value: jsonEncode(user.toJson()),
      );

      // Save user ID
      await secureStorage.write(
        key: AppConstants.userIdKey,
        value: user.id,
      );

      // Save token if provided
      if (token != null && token.isNotEmpty) {
        await secureStorage.write(
          key: AppConstants.authTokenKey,
          value: token,
        );
      }

      developer.log('User data saved successfully', name: 'AuthRepository');
    } catch (e) {
      developer.log('Error saving user data', name: 'AuthRepository', error: e);
      rethrow;
    }
  }

  // Parse User object from API response
  User _parseUserFromResponse(Map<String, dynamic> data) {
    try {
      // Get user data from appropriate location in response
      final userData = data.containsKey('user') ? data['user'] : data;

      final userId = _parseUserId(userData['id']);
      final name = userData['name']?.toString() ?? '';
      final email = userData['email']?.toString() ?? '';
      final tokenBalance = _parseTokenBalance(userData['token_balance'] ?? userData['tokenBalance']);
      final createdAt = _parseDateTime(userData['created_at'] ?? userData['createdAt']);
      final updatedAt = _parseDateTime(userData['updated_at'] ?? userData['updatedAt']);
      final profileImageUrl = userData['profile_image_url']?.toString() ?? userData['profileImageUrl']?.toString();

      return User(
        id: userId,
        name: name,
        email: email,
        tokenBalance: tokenBalance,
        createdAt: createdAt,
        updatedAt: updatedAt,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      developer.log('Error parsing user data: $data', name: 'AuthRepository', error: e);
      rethrow;
    }
  }

  @override
  Future<Either<AuthFailure, User>> login(String email, String password) async {
    try {
      developer.log('Attempting login for email: $email', name: 'AuthRepository');

      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      // Successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        developer.log('Login successful', name: 'AuthRepository');

        // Extract token from API response
        final token = data['token']?.toString();

        try {
          // Parse user data
          final user = _parseUserFromResponse(data);

          // Save user data and token
          await _saveUserData(user, token);

          return Right(user);
        } catch (e) {
          developer.log('Error processing login response', name: 'AuthRepository', error: e);
          return Left(UnknownAuthFailure(
            message: 'Error processing user data: ${e.toString()}',
          ));
        }
      } else {
        // Error status code
        final message = response.data['message']?.toString() ?? 'Invalid email or password';
        developer.log('Login failed: $message', name: 'AuthRepository');
        return Left(InvalidCredentialsFailure(
          message: message,
        ));
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      developer.log('Login failed: $errorMessage', name: 'AuthRepository');
      return Left(errorMessage);
    } catch (e) {
      developer.log('Unknown error during login', name: 'AuthRepository', error: e);
      return Left(UnknownAuthFailure(
        message: e.toString(),
      ));
    }
  }

  // Helper method to handle Dio exceptions
  AuthFailure _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const NetworkAuthFailure(
        message: 'Connection timeout. Please check your internet connection.',
      );
    } else if (e.response?.statusCode == 401) {
      return const InvalidCredentialsFailure(
        message: 'Invalid email or password',
      );
    } else if (e.response?.statusCode == 404) {
      return const UserNotFoundFailure(
        message: 'User not found',
      );
    } else if (e.response?.statusCode == 422) {
      // Validation error handling
      final errors = e.response?.data['errors'];
      if (errors is Map) {
        if (errors.containsKey('email')) {
          return const EmailAlreadyInUseFailure(
            message: 'Email is already in use',
          );
        } else if (errors.containsKey('password')) {
          return const WeakPasswordFailure(
            message: 'Password is too weak',
          );
        }
      }
    }

    return ServerAuthFailure(
      message: e.response?.data['message']?.toString() ?? 'Server error: ${e.message}',
    );
  }

  @override
  Future<Either<AuthFailure, User>> register(String name, String email, String password) async {
    try {
      developer.log('Attempting registration for email: $email', name: 'AuthRepository');

      final response = await _dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );

      // Successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        developer.log('Registration successful', name: 'AuthRepository');

        // Extract token from API response
        final token = data['token']?.toString();

        try {
          // Parse user data
          final user = _parseUserFromResponse(data);

          // Save user data and token
          await _saveUserData(user, token);

          return Right(user);
        } catch (e) {
          developer.log('Error processing registration response', name: 'AuthRepository', error: e);
          return Left(UnknownAuthFailure(
            message: 'Error processing user data: ${e.toString()}',
          ));
        }
      } else {
        // Error status code
        final message = response.data['message']?.toString() ?? 'Registration failed';
        developer.log('Registration failed: $message', name: 'AuthRepository');
        return Left(UnknownAuthFailure(
          message: message,
        ));
      }
    } on DioException catch (e) {
      final errorMessage = _handleDioException(e);
      developer.log('Registration failed: ${errorMessage.message}', name: 'AuthRepository');
      return Left(errorMessage);
    } catch (e) {
      developer.log('Unknown error during registration', name: 'AuthRepository', error: e);
      return Left(UnknownAuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> logout() async {
    try {
      developer.log('Attempting logout', name: 'AuthRepository');

      // Get token
      final token = await secureStorage.read(key: AppConstants.authTokenKey);

      if (token != null) {
        try {
          // Send logout request to API
          await _dio.post(
            '/logout',
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );
          developer.log('Logout API call successful', name: 'AuthRepository');
        } catch (e) {
          // Continue even if API request fails
          developer.log('API logout failed, continuing with local logout', name: 'AuthRepository', error: e);
        }
      }

      // Clear local data
      await secureStorage.delete(key: AppConstants.authTokenKey);
      await secureStorage.delete(key: AppConstants.userIdKey);
      await secureStorage.delete(key: 'user_data');

      developer.log('Local user data cleared successfully', name: 'AuthRepository');
      return const Right(true);
    } catch (e) {
      developer.log('Error during logout', name: 'AuthRepository', error: e);
      return Left(UnknownAuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<AuthFailure, User?>> getCurrentUser() async {
    try {
      developer.log('Fetching current user', name: 'AuthRepository');

      final token = await secureStorage.read(key: AppConstants.authTokenKey);

      if (token == null) {
        developer.log('No auth token found, user not logged in', name: 'AuthRepository');
        return const Right(null);
      }

      // Try to get user data from API
      try {
        developer.log('Attempting to fetch user data from API', name: 'AuthRepository');
        final response = await _dio.get(
          '/user',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          developer.log('User data fetched successfully from API', name: 'AuthRepository');

          try {
            final user = _parseUserFromResponse(data);

            // Save updated user data to local storage
            await secureStorage.write(
              key: 'user_data',
              value: jsonEncode(user.toJson()),
            );

            return Right(user);
          } catch (e) {
            developer.log('Error parsing user data from API', name: 'AuthRepository', error: e);
            // Fall back to local data
          }
        }
      } catch (e) {
        developer.log('API request failed, falling back to local data', name: 'AuthRepository', error: e);
        // Fall back to local data
      }

      // Get user data from local storage
      final userData = await secureStorage.read(key: 'user_data');

      if (userData == null) {
        developer.log('No local user data found', name: 'AuthRepository');
        return const Right(null);
      }

      try {
        final user = User.fromJson(jsonDecode(userData));
        developer.log('User data retrieved from local storage', name: 'AuthRepository');
        return Right(user);
      } catch (e) {
        developer.log('Error parsing user data from local storage', name: 'AuthRepository', error: e);
        return Left(UnknownAuthFailure(
          message: 'Error parsing stored user data: ${e.toString()}',
        ));
      }
    } catch (e) {
      developer.log('Unknown error getting current user', name: 'AuthRepository', error: e);
      return Left(UnknownAuthFailure(
        message: e.toString(),
      ));
    }
  }

  @override
  Future<Either<AuthFailure, User>> updateUserTokenBalance(double newBalance) async {
    try {
      developer.log('Updating token balance to: $newBalance', name: 'AuthRepository');

      final token = await secureStorage.read(key: AppConstants.authTokenKey);
      final user_id = await secureStorage.read(key: AppConstants.userIdKey);

      if (token == null) {
        developer.log('No auth token found, cannot update balance', name: 'AuthRepository');
        return const Left(UserNotFoundFailure(
          message: 'User not found, please log in again',
        ));
      }

      // Send update request to API
      try {
        final response = await _dio.post(
          '/claim-reward',
          data: {
            'user_id': user_id,
            'reward_amount': newBalance,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        );

        if (response.statusCode == 200) {
          final data = response.data;
          developer.log('Token balance updated successfully on server', name: 'AuthRepository');

          try {
            final user = _parseUserFromResponse(data);

            // Save updated user data to local storage
            await _saveUserData(user, null);

            return Right(user);
          } catch (e) {
            developer.log('Error parsing user data after balance update', name: 'AuthRepository', error: e);
            return Left(UnknownAuthFailure(
              message: 'Error processing user data: ${e.toString()}',
            ));
          }
        } else {
          // Error status code
          final message = response.data['message']?.toString() ?? 'Failed to update token balance';
          developer.log('API balance update failed: $message', name: 'AuthRepository');
          return Left(ServerAuthFailure(
            message: message,
          ));
        }
      } catch (e) {
        developer.log('API balance update failed, updating local data instead', name: 'AuthRepository', error: e);

        // If API request fails, update local data
        final userData = await secureStorage.read(key: 'user_data');

        if (userData == null) {
          return const Left(UserNotFoundFailure(
            message: 'User data not found',
          ));
        }

        try {
          final user = User.fromJson(jsonDecode(userData));
          final updatedUser = user.copyWith(
            tokenBalance: newBalance,
            updatedAt: DateTime.now(),
          );

          await secureStorage.write(
            key: 'user_data',
            value: jsonEncode(updatedUser.toJson()),
          );

          developer.log('Token balance updated locally', name: 'AuthRepository');
          return Right(updatedUser);
        } catch (e) {
          developer.log('Error updating local token balance', name: 'AuthRepository', error: e);
          return Left(UnknownAuthFailure(
            message: 'Error updating local user data: ${e.toString()}',
          ));
        }
      }
    } catch (e) {
      developer.log('Unknown error updating token balance', name: 'AuthRepository', error: e);
      return Left(UnknownAuthFailure(
        message: e.toString(),
      ));
    }
  }
}