import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/model/mixed_models/extended_work.dart';
import 'package:swift_contest/model/services/work_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class WorkRepository {
  Future<Either<Failure, Work>> createWork({
    required String name,
    required String description,
    required List<String> imagesUrls,
  });

  Future<Either<Failure, List<Work>>> getAllWorks();

  Future<Either<Failure, Work>> getWorkById({required String id});

  Future<Either<Failure, Work>> updateWorkById({
    required String id,
    String? name,
    String? description,
    List<String>? imagesUrls,
  });

  Future<Either<Failure, Unit>> deleteWorkById({required String id});

  Future<Either<Failure, Work>> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
  });

  Future<Either<Failure, ExtendedWork>> getExtendedWorkByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, List<ExtendedWork>>> getExtendedWorksByContestId({
    required String contestId,
  });
}

//* Implementation
class WorkRepositoryImpl implements WorkRepository {
  final WorkService _workService;

  WorkRepositoryImpl({required WorkService workService}) : _workService = workService;

  @override
  Future<Either<Failure, Work>> createWork({
    required String name,
    required String description,
    required List<String> imagesUrls,
  }) async {
    try {
      final res = await _workService.createWork(
        name: name,
        description: description,
        imagesUrls: imagesUrls,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Work>>> getAllWorks() async {
    try {
      final res = await _workService.getAllWorks();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> getWorkById({required String id}) async {
    try {
      final res = await _workService.getWorkById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> updateWorkById({
    required String id,
    String? name,
    String? description,
    List<String>? imagesUrls,
  }) async {
    try {
      final res = await _workService.updateWorkById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkById({required String id}) async {
    try {
      await _workService.deleteWorkById(id: id);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
  }) async {
    try {
      final res = await _workService.submitWork(
        contestId: contestId,
        participantId: participantId,
        name: name,
        description: description,
        imagesUrls: imagesUrls,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ExtendedWork>> getExtendedWorkByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final res = await _workService.getExtendedWorkByContestIdAndParticipantId(
        contestId: contestId,
        participantId: participantId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExtendedWork>>> getExtendedWorksByContestId({required String contestId}) async {
    try {
      final res = await _workService.getExtendedWorksByContestId(
        contestId: contestId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
