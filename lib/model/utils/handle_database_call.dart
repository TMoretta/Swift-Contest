import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/auth_exception_to_failure.dart';
import 'package:swift_contest/model/utils/edge_function_exception_to_failure.dart';
import 'package:swift_contest/model/utils/postgrest_exception_to_failure.dart';
import 'package:swift_contest/model/utils/storage_exception_to_failure.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Future<Either<Failure, T>> handleDatabaseCall<T>(Future<Either<Failure, T>> Function() function) async {
  try {
    return await function();
  } on SocketException {
    return Either.left(const NetworkFailure());
  } on ClientException catch (_) {
    return Either.left(ClientFailure());
  } on AuthException catch (e) {
    return Either.left(authExceptionToFailure(e));
  } on PostgrestException catch (e) {
    return Either.left(postgrestExceptionToFailure(e));
  } on FunctionException catch (e) {
    return Either.left(edgeFunctionExceptionToFailure(e));
  } on StorageException catch (e) {
    return Either.left(storageExceptionToFailure(e));
  } catch (_) {
    return Either.left(const Failure());
  }
}