// class Failure {
//   final String message;
//
//   Failure([this.message = 'An error occurred']);
//
//   @override
//   String toString() {
//     return message;
//   }
// }

import 'package:equatable/equatable.dart';

// Base class
class Failure extends Equatable {
  final String message;

  const Failure([this.message = 'An unexpected error occurred.']);

  @override
  List<Object> get props => [message];

  @override
  String toString() => message;
}

// General Failures
class ServerFailure extends Failure {
  const ServerFailure([super.message]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

// Auth/Permission Failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([super.message]);
}

class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([super.message = "You don't have permission to perform this action."]);
}

// Database/API Failures
class InvalidInputFailure extends Failure {
  const InvalidInputFailure([super.message = 'The information provided is invalid.']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested item could not be found.']);
}

class UniqueConstraintFailure extends Failure {
  const UniqueConstraintFailure([super.message = 'This item already exists.']);
}

class InvalidReferenceFailure extends Failure {
  const InvalidReferenceFailure([super.message = 'A referenced item does not exist.']);
}

class DeadlockFailure extends Failure {
  const DeadlockFailure([super.message = 'The server is busy. Please try the action again.']);
}

class TooManyRequestsFailure extends Failure {
  const TooManyRequestsFailure([super.message = 'You have made too many requests. Please wait a moment.']);
}