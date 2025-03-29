import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/contest/contest.dart';
import 'package:swift_contest/model/data_models/contest/contest_status.dart';
import 'package:swift_contest/model/data_models/contest/place.dart';
import 'package:swift_contest/model/mixed_models/extended_contest.dart';
import 'package:swift_contest/model/services/contest_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ContestRepository {
  Future<Either<Failure, Contest>> createContest({
    required String name,
    required String description,
    required String organizerId,
    required Place place,
    required bool worksPreviewJurors,
    required DateTime dateTime,
    required DateTime worksDateTimeFrom,
    required DateTime worksDateTimeTo,
    required List<String> imagesUrls,
  });

  Future<Either<Failure, List<Contest>>> getAllContests();

  Future<Either<Failure, Contest>> getContestById({required String id});

  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({required String organizerId});

  Future<Either<Failure, Contest>> updateContestById({
    required String id,
    String? name,
    String? description,
    String? organizerId,
    Place? place,
    bool? worksPreviewJurors,
    DateTime? dateTime,
    DateTime? worksDateTimeFrom,
    DateTime? worksDateTimeTo,
    ContestStatus? status,
    List<String>? imagesUrls,
    bool? isAlive,
  });

  Future<Either<Failure, Unit>> deleteContestById({required String id});

  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByOrganizerId({
    required String organizerId,
  });

  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByParticipantId({
    required String participantId,
  });

  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByJurorId({
    required String jurorId,
  });

  Future<Either<Failure, ExtendedContest>> getExtendedContestByContestId({
    required String contestId,
  });
}

//* Implementation
class ContestRepositoryImpl implements ContestRepository {
  final ContestService _contestService;

  ContestRepositoryImpl({
    required ContestService contestService,
  }) : _contestService = contestService;

  @override
  Future<Either<Failure, Contest>> createContest({
    required String name,
    required String description,
    required String organizerId,
    required Place place,
    required bool worksPreviewJurors,
    required DateTime dateTime,
    required DateTime worksDateTimeFrom,
    required DateTime worksDateTimeTo,
    required List<String> imagesUrls,
  }) async {
    try {
      final today = DateTime.now();

      late final ContestStatus status;
      if (today.isBefore(worksDateTimeFrom)) {
        status = ContestStatus.preparationPhase;
      } else if (today.isAfter(worksDateTimeTo)) {
        status = ContestStatus.votingPhase;
      } else {
        status = ContestStatus.participationPhase;
      }

      final contest = Contest(
        id: '',
        name: name,
        description: description,
        organizerId: organizerId,
        place: place,
        worksPreviewJurors: worksPreviewJurors,
        dateTime: dateTime,
        worksDateTimeFrom: worksDateTimeFrom,
        worksDateTimeTo: worksDateTimeTo,
        status: status,
        imagesUrls: imagesUrls,
        token: '',
        votingFormId: '',
        isAlive: true,
      );
      final res = await _contestService.createContest(contest: contest);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getAllContests() async {
    try {
      final res = await _contestService.getAllContests();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Contest>> getContestById({required String id}) async {
    try {
      final res = await _contestService.getContestById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Contest>>> getContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final res = await _contestService.getContestsByOrganizerId(organizerId: organizerId);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Contest>> updateContestById({
    required String id,
    String? name,
    String? description,
    String? organizerId,
    Place? place,
    bool? worksPreviewJurors,
    DateTime? dateTime,
    DateTime? worksDateTimeFrom,
    DateTime? worksDateTimeTo,
    ContestStatus? status,
    List<String>? imagesUrls,
    bool? isAlive,
  }) async {
    try {
      final res = await _contestService.updateContestById(
        id: id,
        name: name,
        description: description,
        organizerId: organizerId,
        place: place,
        worksPreviewJurors: worksPreviewJurors,
        dateTime: dateTime,
        worksDateTimeFrom: worksDateTimeFrom,
        worksDateTimeTo: worksDateTimeTo,
        status: status,
        imagesUrls: imagesUrls,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteContestById({required String id}) async {
    try {
      await _contestService.deleteContestById(id: id);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByOrganizerId({
    required String organizerId,
  }) async {
    try {
      final res = await _contestService.getExtendedContestsByOrganizerId(organizerId: organizerId);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByParticipantId({
    required String participantId,
  }) async {
    try {
      final res =
          await _contestService.getExtendedContestsByParticipantId(participantId: participantId);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<ExtendedContest>>> getExtendedContestsByJurorId({
    required String jurorId,
  }) async {
    try {
      final res = await _contestService.getExtendedContestsByJurorId(jurorId: jurorId);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ExtendedContest>> getExtendedContestByContestId({
    required String contestId,
  }) async {
    try {
      final res = await _contestService.getExtendedContestByContestId(contestId: contestId);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
