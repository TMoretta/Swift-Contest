import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/auth_exception_to_failure.dart';
import 'package:swift_contest/model/utils/postgrest_exception_to_failure.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Future<Either<Failure, T>> handleDatabaseCall<T>(Future<Either<Failure, T>> Function() function) async {
  try {
    return await function();
  } on SocketException {
    return Either.left(Failure('Network error'));
  } on AuthException catch (e) {
    return Either.left(authExceptionToFailure(e));
  } on PostgrestException catch (e) {
    return Either.left(postgrestExceptionToFailure(e));
  } on FunctionException catch (e) {
    final message = (e.details as Map<String, dynamic>?)?['error'] as String?;
    return Either.left((message != null) ? Failure(message) : Failure());
  } on StorageException catch (e) {
    return Either.left(Failure(e.message));
  } catch (e) {
    return Either.left(Failure());
  }
}
