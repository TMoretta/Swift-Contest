import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/services/contest_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ContestRepository {
  Future<Either<Failure, Contest>> createContest({required Contest contest});

  Future<Either<Failure, Contest>> updateContest({
    required Contest contest,
  });

  Future<Either<Failure, Unit>> deleteContestById({required String id});

  Future<Either<Failure, List<Contest>>> getAllContests();

  Future<Either<Failure, Contest>> getContestById({required String id});

  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({required String organizerId});

  Future<Either<Failure, Contest>> getContestByToken({required String token});
}

//* Implementation
class ContestRepositoryImpl implements ContestRepository {
  final ContestService _contestService;

  ContestRepositoryImpl({required ContestService contestService})
      : _contestService = contestService;

  @override
  Future<Either<Failure, Contest>> createContest({required Contest contest}) async {
    try {
      final result = await _contestService.createContest(contest: contest);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Contest>> updateContest({
    required Contest contest,
  }) async {
    try {
      final result = await _contestService.updateContest(contest: contest);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteContestById({required String id}) async {
    try {
      final result = await _contestService.deleteContestById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getAllContests() async {
    try {
      final result = await _contestService.getAllContests();
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Contest>> getContestById({required String id}) async {
    try {
      final result = await _contestService.getContestById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final result = await _contestService.getContestsByOrganizerId(organizerId: organizerId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Contest>> getContestByToken({required String token}) async {
    try {
      final result = await _contestService.getContestByToken(token: token);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
