import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/simple_juror_vote.dart';
import 'package:swift_contest/model/services/simple_juror_vote_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class SimpleJurorVoteRepository {
  Future<Either<Failure, SimpleJurorVote>> createSimpleJurorVote({
    required SimpleJurorVote simpleJurorVote,
  });

  Future<Either<Failure, SimpleJurorVote>> updateSimpleJurorVoteById({
    required String id,
    required SimpleJurorVote simpleJurorVote,
  });

  Future<Either<Failure, Unit>> deleteSimpleJurorVoteById({
    required String id,
  });

  Future<Either<Failure, SimpleJurorVote>> getSimpleJurorVoteById({
    required String id,
  });

  Future<Either<Failure, List<SimpleJurorVote>>>
      getSimpleJurorVotesBySimpleJurorVotingId({
    required String simpleJurorVotingId,
  });
}

//* Implementation
class SimpleJurorVoteRepositoryImpl implements SimpleJurorVoteRepository {
  final SimpleJurorVoteService _simpleJurorVoteService;

  SimpleJurorVoteRepositoryImpl(
      {required SimpleJurorVoteService simpleJurorVoteService})
      : _simpleJurorVoteService = simpleJurorVoteService;

  @override
  Future<Either<Failure, SimpleJurorVote>> createSimpleJurorVote({
    required SimpleJurorVote simpleJurorVote,
  }) async {
    try {
      final result = await _simpleJurorVoteService.createSimpleJurorVote(
          simpleJurorVote: simpleJurorVote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSimpleJurorVoteById({
    required String id,
  }) async {
    try {
      final result =
          await _simpleJurorVoteService.deleteSimpleJurorVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> getSimpleJurorVoteById({
    required String id,
  }) async {
    try {
      final result =
          await _simpleJurorVoteService.getSimpleJurorVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<SimpleJurorVote>>>
      getSimpleJurorVotesBySimpleJurorVotingId({
    required String simpleJurorVotingId,
  }) async {
    try {
      final result = await _simpleJurorVoteService
          .getSimpleJurorVotesBySimpleJurorVotingId(
              simpleJurorVotingId: simpleJurorVotingId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, SimpleJurorVote>> updateSimpleJurorVoteById({
    required String id,
    required SimpleJurorVote simpleJurorVote,
  }) async {
    try {
      final result = await _simpleJurorVoteService.updateSimpleJurorVoteById(
          id: id, simpleJurorVote: simpleJurorVote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
