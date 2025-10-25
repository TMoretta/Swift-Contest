//* Map the supabase auth exceptions to my custom server exception
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure authExceptionToFailure(AuthException exception) {
  switch (exception.code) {
    //* Supabase exceptions
    case 'email_address_invalid':
      return AuthenticationFailure(exception.message);
    case 'email_exists':
      return AuthenticationFailure(exception.message);
    case 'email_not_confirmed':
      return AuthenticationFailure(exception.message);
    case 'invalid_credentials':
      return AuthenticationFailure(exception.message);
    case 'over_request_rate_limit':
      return AuthenticationFailure(exception.message);
    case 'reauthentication_needed':
      return AuthenticationFailure(exception.message);
    case 'request_timeout':
      return AuthenticationFailure(exception.message);
    case 'session_expired':
      return AuthenticationFailure(exception.message);
    case 'session_not_found':
      return AuthenticationFailure(exception.message);
    case 'unexpected_failure':
      return AuthenticationFailure(exception.message);
    case 'user_already_exists':
      return AuthenticationFailure(exception.message);
    case 'user_banned':
      return AuthenticationFailure(exception.message);
    case 'user_not_found':
      return AuthenticationFailure(exception.message);
    case 'validation_failed':
      return AuthenticationFailure(exception.message);
    case 'weak_password':
      return AuthenticationFailure(exception.message);
    case 'otp_disabled':
      return const AuthenticationFailure('User not found, sign up instead');
    case 'over_email_send_rate_limit':
      return AuthenticationFailure(exception.message);
    case 'otp_expired':
      return AuthenticationFailure(exception.message);
    default:
      return const AuthenticationFailure();
  }
}
