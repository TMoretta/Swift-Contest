import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure postgrestExceptionToFailure(PostgrestException exception) {
  // For developers: log the full error to the console during debug.
  // This should not be shown to the user.
  // print('PostgrestException: Code=${exception.code}, Message=${exception.message}, Details=${exception.details}');

  if(exception.code == 'P0001') {
    return ServerFailure(exception.message);
  }

  // Mapping based on specific error codes
  switch (exception.code) {
  // --- GROUP 0: CONNECTION (PostgREST) ---
    case 'PGRST000':
    case 'PGRST001':
    case 'PGRST002':
    case 'PGRST003':
    // --- Class 08: Connection Exception (PostgreSQL) ---
    case '08000':
    case '08003':
    case '08006':
    case '08001':
    case '08004':
    case '08007':
    case '08P01':
      return const NetworkFailure('Could not connect to the server. Please try again later.');

  // --- GROUP 3: JWT (PostgREST) ---
    case 'PGRST301':
    case 'PGRST302':
    case 'PGRST303':
    // --- Class 28: Invalid Authorization (PostgreSQL) ---
    case '28000':
    case '28P01': // invalid_password
      return const AuthenticationFailure('Your session is invalid or has expired. Please log in again.');

  // --- Class 23: Integrity Constraint Violation ---
    case '23502': // not_null_violation
      return const InvalidInputFailure('A required piece of information was missing.');
    case '23503': // foreign_key_violation
      return const InvalidReferenceFailure('The item you are trying to reference does not exist.');
    case '23505': // unique_violation
      return const UniqueConstraintFailure('This item already exists. Please use a different value.');
    case '23001': // restrict_violation
    case '23514': // check_violation
    case '23P01': // exclusion_violation
      return const InvalidInputFailure('The operation violates a data integrity rule.');

  // --- Class 42: Syntax Error or Access Rule Violation ---
    case '42501': // insufficient_privilege
      return const PermissionDeniedFailure();
    case '42601': // syntax_error
    case '42703': // undefined_column
    case '42883': // undefined_function
    case '42P01': // undefined_table
    // These are developer errors, but we show a generic server failure to the user.
      return const ServerFailure('A server error occurred due to an invalid query.');

  // --- Class 40: Transaction Rollback ---
    case '40P01': // deadlock_detected
      return const DeadlockFailure();
    case '40001': // serialization_failure
      return const ServerFailure('A concurrency error occurred. Please try again.');

  // --- Class 53: Insufficient Resources ---
    case '53100': // disk_full
    case '53200': // out_of_memory
    case '53300': // too_many_connections
      return const ServerFailure('The server is currently experiencing high load. Please try again later.');

  // --- Class 57: Operator Intervention ---
    case '57014': // query_canceled
      return const ServerFailure('The operation was canceled by the administrator.');
    case '57P01': // admin_shutdown
    case '57P03': // cannot_connect_now
      return const ServerFailure('The server is currently undergoing maintenance.');

  // --- GROUP 2: SCHEMA CACHE (PostgREST) ---
    case 'PGRST200':
    case 'PGRST201':
    case 'PGRST202':
    case 'PGRST203':
    case 'PGRST204':
      return const ServerFailure('A server configuration error occurred. Please contact support.');

  // --- GROUP 1: API REQUEST (PostgREST) ---
    case 'PGRST100':
    case 'PGRST102':
    case 'PGRST103':
    case 'PGRST108':
    case 'PGRST114':
    case 'PGRST115':
    case 'PGRST118':
    case 'PGRST120':
    case 'PGRST122':
      return const InvalidInputFailure('The request contained invalid data.');

    case 'PGRST106':
    case 'PGRST125':
    case 'PGRST205':
      return const NotFoundFailure('The requested resource could not be found.');

  // --- Default for all other unhandled codes ---
    default:
    // For any unmapped codes, return a generic and safe server error.
    // This prevents leaking technical details for unexpected errors.
      return const ServerFailure('An unexpected database error occurred.');
  }
}