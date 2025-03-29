import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/services/participation_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ParticipationRepository {
  Future<Either<Failure, Participation>> createParticipation({
    required String contestId,
    required String participantId,
    required String inviteEmail,
    required String workId,
  });

  Future<Either<Failure, Participation>> createParticipationInvite({
    required String contestId,
    required String inviteEmail,
  });

  Future<Either<Failure, List<Participation>>> getAllParticipations();

  Future<Either<Failure, Participation>> getParticipationById({required String id});

  Future<Either<Failure, List<Participation>>> getParticipationsByContestId(
      {required String contestId});

  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId({
    required String participantId,
  });

  Future<Either<Failure, Participation>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, Participation>> updateParticipationById({
    required String id,
    String? contestId,
    String? participantId,
    String? inviteEmail,
    String? workId,
  });

  Future<Either<Failure, Unit>> deleteParticipationById({required String id});

  Future<Either<Failure, Participation>> joinContestAsParticipant({
    required String participantId,
    required String contestToken,
    required String participantToken,
  });
}

//* Implementation
class ParticipationRepositoryImpl implements ParticipationRepository {
  final ParticipationService _participationService;

  ParticipationRepositoryImpl({required ParticipationService participationService})
      : _participationService = participationService;

  @override
  Future<Either<Failure, Participation>> createParticipation({
    required String contestId,
    required String participantId,
    required String inviteEmail,
    required String workId,
  }) async {
    try {
      final res = await _participationService.createParticipation(
        contestId: contestId,
        participantId: participantId,
        inviteEmail: inviteEmail,
        workId: workId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> createParticipationInvite({
    required String contestId,
    required String inviteEmail,
  }) async {
    try {
      final res = await _participationService.createParticipationInvite(
        contestId: contestId,
        inviteEmail: inviteEmail,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getAllParticipations() async {
    try {
      final res = await _participationService.getAllParticipations();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> getParticipationById({
    required String id,
  }) async {
    try {
      final res = await _participationService.getParticipationById(
        id: id,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByContestId({
    required String contestId,
  }) async {
    try {
      final res = await _participationService.getParticipationsByContestId(
        contestId: contestId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Participation>>> getParticipationsByParticipantId({
    required String participantId,
  }) async {
    try {
      final res = await _participationService.getParticipationsByParticipantId(
        participantId: participantId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> getParticipationByContestIdAndParticipantId({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final res = await _participationService.getParticipationByContestIdAndParticipantId(
        contestId: contestId,
        participantId: participantId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> updateParticipationById({
    required String id,
    String? contestId,
    String? participantId,
    String? inviteEmail,
    String? workId,
  }) async {
    try {
      final res = await _participationService.updateParticipationById(
        id: id,
        contestId: contestId,
        participantId: participantId,
        inviteEmail: inviteEmail,
        workId: workId,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteParticipationById({required String id}) async {
    try {
      await _participationService.deleteParticipationById(id: id);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Participation>> joinContestAsParticipant({
    required String participantId,
    required String contestToken,
    required String participantToken,
  }) async {
    try {
      final res = await _participationService.joinContestAsParticipant(
        participantId: participantId,
        contestToken: contestToken,
        participantToken: participantToken,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
