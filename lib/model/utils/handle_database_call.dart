import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/auth_exception_to_failure.dart';
import 'package:swift_contest/model/utils/edge_function_exception_to_failure.dart';
import 'package:swift_contest/model/utils/postgrest_exception_to_failure.dart';
import 'package:swift_contest/model/utils/storage_exception_to_failure.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/logger/logger.dart';

Future<Either<Failure, T>> handleDatabaseCall<T>(Future<Either<Failure, T>> Function() function) async {
  try {
    return await function();
  } on SocketException catch (e) {
    Logger.error('Network error: $e');
    return Either.left(const NetworkFailure());
  } on AuthException catch (e) {
    Logger.warning('Auth error: $e');
    return Either.left(authExceptionToFailure(e));
  } on PostgrestException catch (e) {
    Logger.warning('Postgrest error: $e');
    return Either.left(postgrestExceptionToFailure(e));
  } on FunctionException catch (e) {
    Logger.warning('Edge function error: $e');
    return Either.left(edgeFunctionExceptionToFailure(e));
  } on StorageException catch (e) {
    Logger.warning('Storage error: $e');
    return Either.left(storageExceptionToFailure(e));
  } catch (e) {
    Logger.error('Unknown error: $e');
    return Either.left(const Failure());
  }
}