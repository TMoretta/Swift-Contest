import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/participation.dart';
import 'package:swift_contest/model/services/participation_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ParticipationRepository {
  Future<Either<Failure, Participation>> createParticipation({
    required Participation participation,
  });

  Future<Either<Failure, Participation>> updateParticipation({
    required Participation participation,
  });

  // Future<Either<Failure, Participation>> updateParticipationByContestIdAndParticipantId({
  //   required String contestId,
  //   required String participantId,
  //   required Participation participation,
  // });

  Future<Either<Failure, Unit>> deleteParticipationById({required String id});

  Future<Either<Failure, Participation>> getParticipationById({required String id});

  Future<Either<Failure, Participation>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, List<Participation>>> getParticipationsByContestId({
    required String contestId,
  });

  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId({
    required String participantId,
  });
}

//* Implementation
class ParticipationRepositoryImpl implements ParticipationRepository {
  final ParticipationService _participationService;

  ParticipationRepositoryImpl({required ParticipationService participationService})
      : _participationService = participationService;

  @override
  Future<Either<Failure, Participation>> createParticipation({
    required Participation participation,
  }) async {
    try {
      final result = await _participationService.createParticipation(participation: participation);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> updateParticipation({
    required Participation participation,
  }) async {
    try {
      final result =
          await _participationService.updateParticipation(participation: participation);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  // @override
  // Future<Either<Failure, Participation>> updateParticipationByContestIdAndParticipantId({
  //   required String contestId,
  //   required String participantId,
  //   required Participation participation,
  // }) async {
  //   try {
  //     final result =
  //     await _participationService.updateParticipationByContestIdAndParticipantId(contestId: contestId,participantId: participantId,participation: participation);
  //     return right(result);
  //   } on CustomException catch (e) {
  //     return left(Failure(message: e.message));
  //   }
  // }

  @override
  Future<Either<Failure, Unit>> deleteParticipationById({required String id}) async {
    try {
      final result = await _participationService.deleteParticipationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final result = await _participationService.getParticipationByContestIdAndParticipantId(
          contestId: contestId, participantId: participantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> getParticipationById({required String id}) async {
    try {
      final result = await _participationService.getParticipationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByContestId({
    required String contestId,
  }) async {
    try {
      final result = await _participationService.getParticipationsByContestId(contestId: contestId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId(
      {required String participantId}) async {
    try {
      final result = await _participationService.getParticipationsByParticipantId(
          participantId: participantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
