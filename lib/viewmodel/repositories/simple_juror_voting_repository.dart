import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/simple_juror_voting.dart';
import 'package:swift_contest/model/services/simple_juror_voting_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class SimpleJurorVotingRepository {
  Future<Either<Failure, SimpleJurorVoting>> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<Either<Failure, SimpleJurorVoting>> updateSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  });

  Future<Either<Failure, Unit>> deleteSimpleJurorVotingById({
    required String id,
  });

  Future<Either<Failure, SimpleJurorVoting>> getSimpleJurorVotingById({
    required String id,
  });

  Future<Either<Failure, List<SimpleJurorVoting>>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  });

  Future<Either<Failure, SimpleJurorVoting>>
      getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipantId,
  });
}

class SimpleJurorVotingRepositoryImpl implements SimpleJurorVotingRepository {
  final SimpleJurorVotingService _simpleJurorVotingService;

  SimpleJurorVotingRepositoryImpl(
      {required SimpleJurorVotingService simpleJurorVotingService})
      : _simpleJurorVotingService = simpleJurorVotingService;

  @override
  Future<Either<Failure, SimpleJurorVoting>> createSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final result = await _simpleJurorVotingService.createSimpleJurorVoting(
          simpleJurorVoting: simpleJurorVoting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final result =
          await _simpleJurorVotingService.deleteSimpleJurorVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> getSimpleJurorVotingById({
    required String id,
  }) async {
    try {
      final result =
          await _simpleJurorVotingService.getSimpleJurorVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVoting>>>
      getSimpleJurorVotingsByVotingSessionSimpleJurorId({
    required String votingSessionSimpleJurorId,
  }) async {
    try {
      final result = await _simpleJurorVotingService
          .getSimpleJurorVotingsByVotingSessionSimpleJurorId(
              votingSessionSimpleJurorId: votingSessionSimpleJurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>> updateSimpleJurorVoting({
    required SimpleJurorVoting simpleJurorVoting,
  }) async {
    try {
      final result =
          await _simpleJurorVotingService.updateSimpleJurorVoting(simpleJurorVoting: simpleJurorVoting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVoting>>
      getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId({
    required String votingSessionSimpleJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final result = await _simpleJurorVotingService
          .getVotingByVotingSessionSimpleJurorIdAndVotingSessionParticipantId(
              votingSessionSimpleJurorId: votingSessionSimpleJurorId,
              votingSessionParticipantId: votingSessionParticipantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
