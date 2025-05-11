import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/model/services/work_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class WorkRepository {
  Future<Either<Failure, Work>> createWork({required Work work});

  Future<Either<Failure, Work>> updateWorkById(
      {required String id, required Work work});

  Future<Either<Failure, Unit>> deleteWorkById({required String id});

  Future<Either<Failure, Work>> getWorkById({required String id});

  Future<Either<Failure, Work>> getWorkByParticipationId({
    required String participationId,
  });
}

//* Implementation
class WorkRepositoryImpl implements WorkRepository {
  final WorkService _workService;

  WorkRepositoryImpl({required WorkService workService})
      : _workService = workService;

  @override
  Future<Either<Failure, Work>> createWork({required Work work}) async {
    try {
      final result = await _workService.createWork(work: work);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteWorkById({required String id}) async {
    try {
      final result = await _workService.deleteWorkById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> getWorkById({required String id}) async {
    try {
      final result = await _workService.getWorkById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> getWorkByParticipationId({
    required String participationId,
  }) async {
    try {
      final result = await _workService.getWorkByParticipationId(participationId: participationId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Work>> updateWorkById(
      {required String id, required Work work}) async {
    try {
      final result = await _workService.updateWorkById(id: id, work: work);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
