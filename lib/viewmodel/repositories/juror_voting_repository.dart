import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/juror_voting.dart';
import 'package:swift_contest/model/services/juror_voting_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class JurorVotingRepository {
  Future<Either<Failure, JurorVoting>> createJurorVoting({required JurorVoting jurorVoting});

  Future<Either<Failure, JurorVoting>> updateJurorVoting({required JurorVoting jurorVoting});

  Future<Either<Failure, Unit>> deleteJurorVotingById({required String id});

  Future<Either<Failure, JurorVoting>> getJurorVotingById({required String id});

  Future<Either<Failure, JurorVoting>> getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  });

  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  });

  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  });
}

//* Implementation
class JurorVotingRepositoryImpl implements JurorVotingRepository {
  final JurorVotingService _jurorVotingService;

  JurorVotingRepositoryImpl({required JurorVotingService jurorVotingService}) : _jurorVotingService = jurorVotingService;

  @override
  Future<Either<Failure, JurorVoting>> createJurorVoting({required JurorVoting jurorVoting}) async {
    try {
      final result = await _jurorVotingService.createJurorVoting(jurorVoting: jurorVoting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJurorVotingById({required String id}) async {
    try {
      final result = await _jurorVotingService.deleteJurorVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> getJurorVotingById({required String id}) async {
    try {
      final result = await _jurorVotingService.getJurorVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final result =
          await _jurorVotingService.getJurorVotingByVotingSessionJurorIdAndVotingSessionParticipantId(
              votingSessionJurorId: votingSessionJurorId,
              votingSessionParticipantId: votingSessionParticipantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  }) async {
    try {
      final result = await _jurorVotingService.getJurorVotingsByVotingSessionJurorId(
          votingSessionJurorId: votingSessionJurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<JurorVoting>>> getJurorVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  }) async {
    try {
      final result = await _jurorVotingService.getJurorVotingsByVotingSessionParticipantId(
          votingSessionParticipantId: votingSessionParticipantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, JurorVoting>> updateJurorVoting({
    required JurorVoting jurorVoting,
  }) async {
    try {
      final result = await _jurorVotingService.updateJurorVoting(jurorVoting: jurorVoting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
