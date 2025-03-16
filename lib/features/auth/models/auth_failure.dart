import 'package:equatable/equatable.dart';

abstract class AuthFailure extends Equatable {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerAuthFailure extends AuthFailure {
  const ServerAuthFailure({required super.message});
}

class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure({required super.message});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({required super.message});
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({required super.message});
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure({required super.message});
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure({required super.message});
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure({required super.message});
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure({required super.message});
}
