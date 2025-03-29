import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/services/juration_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class JurationRepository {
  Future<Either<Failure, Juration>> createJuration({
    required String contestId,
    required String jurorId,
    required String inviteEmail,
  });

  Future<Either<Failure, Juration>> createJurationInvite({
    required String contestId,
    required String inviteEmail,
  });

  Future<Either<Failure, List<Juration>>> getAllJurations();

  Future<Either<Failure, Juration>> getJurationById({required String id});

  Future<Either<Failure, List<Juration>>> getJurationsByContestId({required String contestId});

  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({required String jurorId});

  Future<Either<Failure, Juration>> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  });

  Future<Either<Failure, Juration>> updateJurationById({
    required String id,
    String? contestId,
    String? jurorId,
    String? inviteEmail,
  });

  Future<Either<Failure, Unit>> deleteJurationById({required String id});

  Future<Either<Failure, Juration>> joinContestAsJuror({
    required String jurorId,
    required String contestToken,
    required String jurorToken,
  });
}

//* Implementation
class JurationRepositoryImpl implements JurationRepository {
  final JurationService _jurationService;

  JurationRepositoryImpl({required JurationService jurationService})
      : _jurationService = jurationService;

  @override
  Future<Either<Failure, Juration>> createJuration({
    required String contestId,
    required String jurorId,
    required String inviteEmail,
  }) async {
    try {
      final res = await _jurationService.createJuration(
        contestId: contestId,
        jurorId: jurorId,
        inviteEmail: inviteEmail,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> createJurationInvite({
    required String contestId,
    required String inviteEmail,
  }) async {
    try {
      final res = await _jurationService.createJurationInvite(
        contestId: contestId,
        inviteEmail: inviteEmail,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getAllJurations() async {
    try {
      final res = await _jurationService.getAllJurations();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> getJurationById({required String id}) async {
    try {
      final res = await _jurationService.getJurationById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByContestId({
    required String contestId,
  }) async {
    try {
      final res = await _jurationService.getJurationsByContestId(
        contestId: contestId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Juration>>> getJurationsByJurorId({
    required String jurorId,
  }) async {
    try {
      final res = await _jurationService.getJurationsByJurorId(
        jurorId: jurorId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> getJurationByContestIdAndJurorId({
    required String contestId,
    required String jurorId,
  }) async {
    try {
      final res = await _jurationService.getJurationByContestIdAndJurorId(
        contestId: contestId,
        jurorId: jurorId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> updateJurationById({
    required String id,
    String? contestId,
    String? jurorId,
    String? inviteEmail,
  }) async {
    try {
      final res = await _jurationService.updateJurationById(
        id: id,
        contestId: contestId,
        jurorId: jurorId,
        inviteEmail: inviteEmail,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJurationById({required String id}) async {
    try {
      await _jurationService.deleteJurationById(id: id);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Juration>> joinContestAsJuror({
    required String jurorId,
    required String contestToken,
    required String jurorToken,
  }) async {
    try {
      final Juration res = await _jurationService.joinContestAsJuror(
        jurorId: jurorId,
        contestToken: contestToken,
        jurorToken: jurorToken,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
