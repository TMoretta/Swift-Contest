import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure postgrestExceptionToFailure( PostgrestException exception) {
  switch (exception.code) {
    default:
      return Failure(exception.message);
  }
}
