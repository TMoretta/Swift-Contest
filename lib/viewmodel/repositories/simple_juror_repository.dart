import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/services/simple_juror_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class SimpleJurorRepository {
  Future<Either<Failure, SimpleJuror>> createSimpleJuror({
    required SimpleJuror simpleJuror,
  });

  Future<Either<Failure, SimpleJuror>> updateSimpleJurorById({
    required String id,
    required SimpleJuror simpleJuror,
  });

  Future<Either<Failure, Unit>> deleteSimpleJurorById({
    required String id,
  });

  Future<Either<Failure, SimpleJuror>> getSimpleJurorById({
    required String id,
  });
}

//* Implementation
class SimpleJurorRepositoryImpl implements SimpleJurorRepository {
  final SimpleJurorService _simpleJurorService;

  SimpleJurorRepositoryImpl({required SimpleJurorService simpleJurorService})
      : _simpleJurorService = simpleJurorService;

  @override
  Future<Either<Failure, SimpleJuror>> createSimpleJuror({
    required SimpleJuror simpleJuror,
  }) async {
    try {
      final result =
          await _simpleJurorService.createSimpleJuror(simpleJuror: simpleJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSimpleJurorById({
    required String id,
  }) async {
    try {
      final result = await _simpleJurorService.deleteSimpleJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJuror>> getSimpleJurorById({
    required String id,
  }) async {
    try {
      final result = await _simpleJurorService.getSimpleJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJuror>> updateSimpleJurorById({
    required String id,
    required SimpleJuror simpleJuror,
  }) async {
    try {
      final result = await _simpleJurorService.updateSimpleJurorById(
          id: id, simpleJuror: simpleJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
