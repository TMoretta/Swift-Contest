import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/services/voting_session_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingSessionRepository {
  Future<Either<Failure, VotingSession>> createVotingSession({
    required VotingSession votingSession,
  });

  Future<Either<Failure, VotingSession>> updateVotingSessionById({
    required String id,
    required VotingSession votingSession,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionById({required String id});

  Future<Either<Failure, VotingSession>> getVotingSessionById({
    required String id,
  });

  Future<Either<Failure, List<VotingSession>>> getVotingSessionsByContestId({
    required String contestId,
  });

  Future<Either<Failure, VotingSession>> getVotingSessionByToken({
    required String token,
  });
}

//* Implementation
class VotingSessionRepositoryImpl implements VotingSessionRepository {
  final VotingSessionService _votingSessionService;

  VotingSessionRepositoryImpl({
    required VotingSessionService votingSessionService,
  }) : _votingSessionService = votingSessionService;

  @override
  Future<Either<Failure, VotingSession>> createVotingSession({
    required VotingSession votingSession,
  }) async {
    try {
      final result = await _votingSessionService.createVotingSession(
          votingSession: votingSession);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionById(
      {required String id}) async {
    try {
      final result =
          await _votingSessionService.deleteVotingSessionById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSession>> getVotingSessionById(
      {required String id}) async {
    try {
      final result = await _votingSessionService.getVotingSessionById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getVotingSessionsByContestId({
    required String contestId,
  }) async {
    try {
      final result = await _votingSessionService.getVotingSessionsByContestId(
          contestId: contestId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSession>> updateVotingSessionById({
    required String id,
    required VotingSession votingSession,
  }) async {
    try {
      final result = await _votingSessionService.updateVotingSessionById(
          id: id, votingSession: votingSession);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSession>> getVotingSessionByToken({
    required String token,
  }) async {
    try {
      final result =
          await _votingSessionService.getVotingSessionByToken(token: token);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
