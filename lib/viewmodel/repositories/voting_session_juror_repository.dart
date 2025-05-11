import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session_juror.dart';
import 'package:swift_contest/model/services/voting_session_juror_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingSessionJurorRepository {
  Future<Either<Failure, VotingSessionJuror>> createVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  });

  Future<Either<Failure, VotingSessionJuror>> updateVotingSessionJurorById({
    required String id,
    required VotingSessionJuror votingSessionJuror,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionJurorById({required String id});

  Future<Either<Failure, VotingSessionJuror>> getVotingSessionJurorById({required String id});

  Future<Either<Failure, VotingSessionJuror>>
      getVotingSessionJurorByVotingSessionIdAndJurorId({
    required String votingSessionId,
    required String jurorId,
  });

  Future<Either<Failure, List<VotingSessionJuror>>> getVotingSessionJurorsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionJurorRepositoryImpl implements VotingSessionJurorRepository {
  final VotingSessionJurorService _votingSessionJurorService;

  VotingSessionJurorRepositoryImpl({required VotingSessionJurorService votingSessionJurorService})
      : _votingSessionJurorService = votingSessionJurorService;

  @override
  Future<Either<Failure, VotingSessionJuror>> createVotingSessionJuror({
    required VotingSessionJuror votingSessionJuror,
  }) async {
    try {
      final result = await _votingSessionJurorService.createVotingSessionJuror(
          votingSessionJuror: votingSessionJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionJurorById({required String id}) async {
    try {
      final result = await _votingSessionJurorService.deleteVotingSessionJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuror>> getVotingSessionJurorById(
      {required String id}) async {
    try {
      final result = await _votingSessionJurorService.getVotingSessionJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuror>>
      getVotingSessionJurorByVotingSessionIdAndJurorId({
    required String votingSessionId,
    required String jurorId,
  }) async {
    try {
      final result = await _votingSessionJurorService
          .getVotingSessionJurorByVotingSessionIdAndJurorId(
              votingSessionId: votingSessionId, jurorId: jurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionJuror>>> getVotingSessionJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final result = await _votingSessionJurorService.getVotingSessionJurorsByVotingSessionId(
          votingSessionId: votingSessionId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionJuror>> updateVotingSessionJurorById({
    required String id,
    required VotingSessionJuror votingSessionJuror,
  }) async {
    try {
      final result = await _votingSessionJurorService.updateVotingSessionJurorById(
          id: id, votingSessionJuror: votingSessionJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
