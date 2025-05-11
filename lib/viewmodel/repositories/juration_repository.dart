import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/services/juration_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class JurationRepository {
  Future<Either<Failure, Juration>> createJuration({required Juration juration});

  Future<Either<Failure, Juration>> updateJurationById({
    required String id,
    required Juration juration,
  });

  Future<Either<Failure, Unit>> deleteJurationById({required String id});

  Future<Either<Failure, Juration>> getJurationById({required String id});

  Future<Either<Failure, Juration>> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  });

  Future<Either<Failure, List<Juration>>> getJurationsByContestId({required String contestId});

  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({required String jurorId});
}

//* Implementation
class JurationRepositoryImpl implements JurationRepository {
  final JurationService _jurationService;

  JurationRepositoryImpl({required JurationService jurationService})
      : _jurationService = jurationService;

  @override
  Future<Either<Failure, Juration>> createJuration({required Juration juration}) async {
    try {
      final result = await _jurationService.createJuration(juration: juration);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> updateJurationById(
      {required String id, required Juration juration}) async {
    try {
      final result = await _jurationService.updateJurationById(id: id, juration: juration);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJurationById({required String id}) async {
    try {
      final result = await _jurationService.deleteJurationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> getJurationById({required String id}) async {
    try {
      final result = await _jurationService.getJurationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> getJurationByContestIdAndJurorId(
      {required String contestId, required String jurorId}) async {
    try {
      final result = await _jurationService.getJurationByContestIdAndJurorId(
          contestId: contestId, jurorId: jurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByContestId(
      {required String contestId}) async {
    try {
      final result = await _jurationService.getJurationsByContestId(contestId: contestId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({required String jurorId}) async {
    try {
      final result = await _jurationService.getJurationsByJurorId(jurorId: jurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
