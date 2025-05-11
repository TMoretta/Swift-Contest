import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session_token.dart';
import 'package:swift_contest/model/services/voting_session_token_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class VotingSessionTokenRepository {
  Future<Either<Failure, VotingSessionToken>> createVotingSessionToken({
    required VotingSessionToken votingSessionToken,
  });

  Future<Either<Failure, VotingSessionToken>> updateVotingSessionTokenById({
    required String id,
    required VotingSessionToken votingSessionToken,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionTokenById({
    required String id,
  });

  Future<Either<Failure, VotingSessionToken>> getVotingSessionTokenById({
    required String id,
  });

  Future<Either<Failure, VotingSessionToken>>
      getVotingSessionTokenByVotingSessionId({
    required String votingSessionId,
  });
}

class VotingSessionTokenRepositoryImpl implements VotingSessionTokenRepository {
  final VotingSessionTokenService _votingSessionTokenService;

  VotingSessionTokenRepositoryImpl(
      {required VotingSessionTokenService votingSessionTokenService})
      : _votingSessionTokenService = votingSessionTokenService;

  @override
  Future<Either<Failure, VotingSessionToken>> createVotingSessionToken({
    required VotingSessionToken votingSessionToken,
  }) async {
    try {
      final result = await _votingSessionTokenService.createVotingSessionToken(
          votingSessionToken: votingSessionToken);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionTokenById({
    required String id,
  }) async {
    try {
      final result =
          await _votingSessionTokenService.deleteVotingSessionTokenById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionToken>> getVotingSessionTokenById({
    required String id,
  }) async {
    try {
      final result =
          await _votingSessionTokenService.getVotingSessionTokenById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionToken>>
      getVotingSessionTokenByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final result = await _votingSessionTokenService
          .getVotingSessionTokenByVotingSessionId(
              votingSessionId: votingSessionId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionToken>> updateVotingSessionTokenById({
    required String id,
    required VotingSessionToken votingSessionToken,
  }) async {
    try {
      final result =
          await _votingSessionTokenService.updateVotingSessionTokenById(
              id: id, votingSessionToken: votingSessionToken);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
