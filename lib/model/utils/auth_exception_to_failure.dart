//* Map the supabase auth exceptions to my custom server exception
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure authExceptionToFailure(AuthException exception) {
  switch (exception.code) {
    // //* Supabase exceptions
    // case 'email_address_invalid':
    //   return Failure(exception.message);
    // case 'email_exists':
    //   return Failure(exception.message);
    // case 'email_not_confirmed':
    //   return Failure(exception.message);
    // case 'invalid_credentials':
    //   return Failure(exception.message);
    // case 'over_request_rate_limit':
    //   return Failure(exception.message);
    // case 'reauthentication_needed':
    //   return Failure(exception.message);
    // case 'request_timeout':
    //   return Failure(exception.message);
    // case 'session_expired':
    //   return Failure(exception.message);
    // case 'session_not_found':
    //   return Failure(exception.message);
    // case 'unexpected_failure':
    //   return Failure(exception.message);
    // case 'user_already_exists':
    //   return Failure(exception.message);
    // case 'user_banned':
    //   return Failure(exception.message);
    // case 'user_not_found':
    //   return Failure(exception.message);
    // case 'validation_failed':
    //   return Failure(exception.message);
    // case 'weak_password':
    //   return Failure(exception.message);
    // case 'otp_disabled':
    //   return Failure(exception.message);
    // case 'over_email_send_rate_limit':
    //   return Failure(exception.message);
    // case 'otp_expired':
    //   return Failure(exception.message);
    default:
      return AuthenticationFailure(exception.message);
  }
}
