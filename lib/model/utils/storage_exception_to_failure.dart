// lib/model/utils/storage_exception_to_failure.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure storageExceptionToFailure(StorageException exception) {
  // Per gli sviluppatori: logga l'errore completo per il debug.
  // Il codice di errore grezzo del server si trova nella proprietà `message`.
  // print('StorageException: Message=${exception.message}, StatusCode=${exception.statusCode}');

  switch (exception.statusCode) {
    case '404':
      return const NotFoundFailure('The requested file or resource could not be found.');

    case '409':
      return const UniqueConstraintFailure('A file with this name already exists.');

    case '403':
      return const PermissionDeniedFailure("You don't have permission to access this resource.");

    case '429':
      return const TooManyRequestsFailure();

    case '544': // Custom database timeout status
    case '500':
      return const ServerFailure('An unexpected server error occurred while accessing storage.');

    default:
    // For any unmapped codes, return a generic and safe server error.
      return const ServerFailure('An unexpected storage error occurred.');
  }
}