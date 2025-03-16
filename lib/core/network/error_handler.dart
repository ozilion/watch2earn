import 'package:dio/dio.dart';
import 'package:watch2earn/core/errors/failure.dart';

class ErrorHandler {
  static Failure handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(
          message: 'Connection timed out. Please try again.',
          code: error.response?.statusCode,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'Unable to connect to the server. Please check your internet connection.',
          code: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return UnknownFailure(
          message: 'Request was cancelled.',
          code: error.response?.statusCode,
        );
      default:
        return UnknownFailure(
          message: error.message ?? 'Something went wrong. Please try again.',
          code: error.response?.statusCode,
        );
    }
  }

  static Failure _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final errorMessage = error.response?.data['status_message'] as String? ??
        error.message ??
        'Something went wrong. Please try again.';

    switch (statusCode) {
      case 400:
        return ValidationFailure(
          message: errorMessage,
          code: statusCode,
        );
      case 401:
        return UnauthorizedFailure(
          message: 'Unauthorized. Please login again.',
          code: statusCode,
        );
      case 404:
        return NotFoundFailure(
          message: 'The requested resource was not found.',
          code: statusCode,
        );
      case 429:
        return ServerFailure(
          message: 'Too many requests. Please try again later.',
          code: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          message: 'Server error. Please try again later.',
          code: statusCode,
        );
      default:
        return ServerFailure(
          message: errorMessage,
          code: statusCode,
        );
    }
  }
}
