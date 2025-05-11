import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting.dart';
import 'package:swift_contest/model/services/voting_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingRepository {
  Future<Either<Failure, Voting>> createVoting({required Voting voting});

  Future<Either<Failure, Voting>> updateVotingById({required String id, required Voting voting});

  Future<Either<Failure, Unit>> deleteVotingById({required String id});

  Future<Either<Failure, Voting>> getVotingById({required String id});

  Future<Either<Failure, Voting>> getVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  });

  Future<Either<Failure, List<Voting>>> getVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  });

  Future<Either<Failure, List<Voting>>> getVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  });
}

//* Implementation
class VotingRepositoryImpl implements VotingRepository {
  final VotingService _votingService;

  VotingRepositoryImpl({required VotingService votingService}) : _votingService = votingService;

  @override
  Future<Either<Failure, Voting>> createVoting({required Voting voting}) async {
    try {
      final result = await _votingService.createVoting(voting: voting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingById({required String id}) async {
    try {
      final result = await _votingService.deleteVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Voting>> getVotingById({required String id}) async {
    try {
      final result = await _votingService.getVotingById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Voting>> getVotingByVotingSessionJurorIdAndVotingSessionParticipantId({
    required String votingSessionJurorId,
    required String votingSessionParticipantId,
  }) async {
    try {
      final result =
          await _votingService.getVotingByVotingSessionJurorIdAndVotingSessionParticipantId(
              votingSessionJurorId: votingSessionJurorId,
              votingSessionParticipantId: votingSessionParticipantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Voting>>> getVotingsByVotingSessionJurorId({
    required String votingSessionJurorId,
  }) async {
    try {
      final result = await _votingService.getVotingsByVotingSessionJurorId(
          votingSessionJurorId: votingSessionJurorId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Voting>>> getVotingsByVotingSessionParticipantId({
    required String votingSessionParticipantId,
  }) async {
    try {
      final result = await _votingService.getVotingsByVotingSessionParticipantId(
          votingSessionParticipantId: votingSessionParticipantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Voting>> updateVotingById({
    required String id,
    required Voting voting,
  }) async {
    try {
      final result = await _votingService.updateVotingById(id: id, voting: voting);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
