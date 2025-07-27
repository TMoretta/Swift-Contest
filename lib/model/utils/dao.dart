import 'package:fpdart/fpdart.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class Dao<T> {
  Future<Either<Failure, T>> create({required T entity});

  Future<Either<Failure, T>> update({required T entity});

  Future<Either<Failure, Unit>> deleteById({required String id});

  Future<Either<Failure, T>> getById({required String id});

  Future<Either<Failure, T?>> getNullableById({required String id});

  Future<Either<Failure, List<T>>> getAll();
}
