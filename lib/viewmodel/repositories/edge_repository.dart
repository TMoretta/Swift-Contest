import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/services/edge_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
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
  Future<Either<Failure, Unit>> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      final result = await _edgeService.sendJurorInvite(jurorToken: jurorToken,contestToken: contestToken,email: email);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      final result = await _edgeService.sendParticipantInvite(participantToken: participantToken,contestToken: contestToken,email: email);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
