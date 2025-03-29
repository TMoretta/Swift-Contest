import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/services/edge_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class EdgeRepository {
  Future<Either<Failure, Unit>> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  });

  Future<Either<Failure, Unit>> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  });
}

//* Implementation
class EdgeRepositoryImpl implements EdgeRepository {
  final EdgeService _edgeService;

  EdgeRepositoryImpl({required EdgeService edgeService}) : _edgeService = edgeService;

  @override
  Future<Either<Failure, Unit>> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      await _edgeService.sendParticipantInvite(
          participantToken: participantToken, contestToken: contestToken, email: email);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      await _edgeService.sendJurorInvite(
          jurorToken: jurorToken, contestToken: contestToken, email: email);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
