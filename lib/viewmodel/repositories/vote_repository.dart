import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/vote.dart';
import 'package:swift_contest/model/services/vote_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VoteRepository {
  Future<Either<Failure, Vote>> createVote({required Vote vote});

  Future<Either<Failure, Vote>> updateVoteById({required String id, required Vote vote});

  Future<Either<Failure, Unit>> deleteVoteById({required String id});

  Future<Either<Failure, Vote>> getVoteById({required String id});

  Future<Either<Failure, List<Vote>>> getVotesByVotingId({required String votingId});
}

//* Implementation
class VoteRepositoryImpl implements VoteRepository {
  final VoteService _voteService;

  VoteRepositoryImpl({required VoteService voteService}) : _voteService = voteService;

  @override
  Future<Either<Failure, Vote>> createVote({required Vote vote}) async {
    try {
      final result = await _voteService.createVote(vote: vote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVoteById({required String id}) async {
    try {
      final result = await _voteService.deleteVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Vote>> getVoteById({required String id}) async {
    try {
      final result = await _voteService.getVoteById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Vote>>> getVotesByVotingId({required String votingId}) async {
    try {
      final result = await _voteService.getVotesByVotingId(votingId: votingId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Vote>> updateVoteById({required String id, required Vote vote}) async {
    try {
      final result = await _voteService.updateVoteById(id: id, vote: vote);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
