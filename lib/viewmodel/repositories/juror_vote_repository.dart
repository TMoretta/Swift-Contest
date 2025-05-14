import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/services/juror_vote_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class JurorVoteRepository {
  Future<Either<Failure, JurorVote>> createJurorVote({required JurorVote jurorVote});

  Future<Either<Failure, JurorVote>> updateJurorVoteById({required String id, required JurorVote jurorVote});

  Future<Either<Failure, Unit>> deleteJurorVoteById({required String id});

  Future<Either<Failure, JurorVote>> getJurorVoteById({required String id});

  Future<Either<Failure, List<JurorVote>>> getJurorVotesByJurorVotingId({required String jurorVotingId});
}

//* Implementation
class JurorVoteRepositoryImpl implements JurorVoteRepository {
  final JurorVoteService _jurorVoteService;

  JurorVoteRepositoryImpl({required JurorVoteService jurorVoteService}) : _jurorVoteService = jurorVoteService;

  @override
  Future<Either<Failure, JurorVote>> createJurorVote({required JurorVote jurorVote}) async {
    try {
      final result = await _jurorVoteService.createJurorVote(jurorVote: jurorVote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJurorVoteById({required String id}) async {
    try {
      final result = await _jurorVoteService.deleteJurorVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, JurorVote>> getJurorVoteById({required String id}) async {
    try {
      final result = await _jurorVoteService.getJurorVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<JurorVote>>> getJurorVotesByJurorVotingId({required String jurorVotingId}) async {
    try {
      final result = await _jurorVoteService.getJurorVotesByJurorVotingId(jurorVotingId: jurorVotingId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, JurorVote>> updateJurorVoteById({required String id, required JurorVote jurorVote}) async {
    try {
      final result = await _jurorVoteService.updateJurorVoteById(id: id, jurorVote: jurorVote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
