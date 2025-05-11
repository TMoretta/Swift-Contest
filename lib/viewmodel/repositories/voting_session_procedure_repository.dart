import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
import 'package:swift_contest/model/services/voting_session_procedure_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class VotingSessionProcedureRepository {
  Future<Either<Failure, VotingSessionProcedure>> createVotingSessionProcedure({
    required VotingSessionProcedure votingSessionProcedure,
  });

  Future<Either<Failure, VotingSessionProcedure>> updateVotingSessionProcedureById({
    required String id,
    required VotingSessionProcedure votingSessionProcedure,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionProcedureById({required String id});

  Future<Either<Failure, VotingSessionProcedure>> getVotingSessionProcedureById({
    required String id,
  });

  Future<Either<Failure, VotingSessionProcedure>> getVotingSessionProcedureByVotingSessionId({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> beginVotingSessionProcedureById({
    required String id,
  });

  Future<Either<Failure, Unit>> startVotingSessionProcedureById({
    required String id,
  });

  Future<Either<Failure, Unit>> cancelVotingSessionProcedureById({
    required String id,
  });

  Future<Either<Failure, Stream<VotingSessionProcedure>>> getVotingSessionProcedureStream({
    required String votingSessionProcedureId,
  });
}

class VotingSessionProcedureRepositoryImpl implements VotingSessionProcedureRepository {
  final VotingSessionProcedureService _votingSessionProcedureService;

  VotingSessionProcedureRepositoryImpl({
    required VotingSessionProcedureService votingSessionProcedureService,
  }) : _votingSessionProcedureService = votingSessionProcedureService;

  @override
  Future<Either<Failure, VotingSessionProcedure>> createVotingSessionProcedure({
    required VotingSessionProcedure votingSessionProcedure,
  }) async {
    try {
      final result = await _votingSessionProcedureService.createVotingSessionProcedure(
          votingSessionProcedure: votingSessionProcedure);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      await _votingSessionProcedureService.deleteVotingSessionProcedureById(id: id);
      return right(unit);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionProcedure>> getVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      final result = await _votingSessionProcedureService.getVotingSessionProcedureById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionProcedure>> getVotingSessionProcedureByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final result = await _votingSessionProcedureService
          .getVotingSessionProcedureByVotingSessionId(votingSessionId: votingSessionId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionProcedure>> updateVotingSessionProcedureById({
    required String id,
    required VotingSessionProcedure votingSessionProcedure,
  }) async {
    try {
      final result = await _votingSessionProcedureService.updateVotingSessionProcedureById(
          id: id, votingSessionProcedure: votingSessionProcedure);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> beginVotingSessionProcedureById({required String id}) async {
    try {
      await _votingSessionProcedureService.beginVotingSessionProcedureById(id: id);
      return right(unit);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> startVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      await _votingSessionProcedureService.startVotingSessionProcedureById(id: id);
      return right(unit);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelVotingSessionProcedureById({
    required String id,
  }) async {
    try {
      await _votingSessionProcedureService.cancelVotingSessionProcedureById(id: id);
      return right(unit);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Stream<VotingSessionProcedure>>> getVotingSessionProcedureStream({
    required String votingSessionProcedureId,
  }) async {
    return right(await _votingSessionProcedureService.getVotingSessionProcedureStream(
        votingSessionProcedureId: votingSessionProcedureId));
  }
}
