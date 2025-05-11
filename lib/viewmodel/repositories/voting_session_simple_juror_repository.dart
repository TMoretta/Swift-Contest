import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session_simple_juror.dart';
import 'package:swift_contest/model/services/voting_session_simple_juror_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class VotingSessionSimpleJurorRepository {
  Future<Either<Failure, VotingSessionSimpleJuror>>
      createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<Either<Failure, VotingSessionSimpleJuror>>
      updateVotingSessionSimpleJurorById({
    required String id,
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionSimpleJurorById({
    required String id,
  });

  Future<Either<Failure, VotingSessionSimpleJuror>>
      getVotingSessionSimpleJurorById({
    required String id,
  });

  Future<Either<Failure, List<VotingSessionSimpleJuror>>>
      getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  });
}

class VotingSessionSimpleJurorRepositoryImpl
    implements VotingSessionSimpleJurorRepository {
  final VotingSessionSimpleJurorService _votingSessionSimpleJurorService;

  VotingSessionSimpleJurorRepositoryImpl({
    required VotingSessionSimpleJurorService votingSessionSimpleJurorService,
  }) : _votingSessionSimpleJurorService = votingSessionSimpleJurorService;

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>>
      createVotingSessionSimpleJuror({
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final result =
          await _votingSessionSimpleJurorService.createVotingSessionSimpleJuror(
              votingSessionSimpleJuror: votingSessionSimpleJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final result = await _votingSessionSimpleJurorService
          .deleteVotingSessionSimpleJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>>
      getVotingSessionSimpleJurorById({
    required String id,
  }) async {
    try {
      final result = await _votingSessionSimpleJurorService
          .getVotingSessionSimpleJurorById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionSimpleJuror>>>
      getVotingSessionSimpleJurorsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final result = await _votingSessionSimpleJurorService
          .getVotingSessionSimpleJurorsByVotingSessionId(
              votingSessionId: votingSessionId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionSimpleJuror>>
      updateVotingSessionSimpleJurorById({
    required String id,
    required VotingSessionSimpleJuror votingSessionSimpleJuror,
  }) async {
    try {
      final result = await _votingSessionSimpleJurorService
          .updateVotingSessionSimpleJurorById(
              id: id, votingSessionSimpleJuror: votingSessionSimpleJuror);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
