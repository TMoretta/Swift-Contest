import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_session_participant.dart';
import 'package:swift_contest/model/services/voting_session_participant_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingSessionParticipantRepository {
  Future<Either<Failure, VotingSessionParticipant>> createVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  });

  Future<Either<Failure, VotingSessionParticipant>> updateVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  });

  Future<Either<Failure, Unit>> deleteVotingSessionParticipantById({required String id});

  Future<Either<Failure, VotingSessionParticipant>> getVotingSessionParticipantById(
      {required String id,});

  Future<Either<Failure, VotingSessionParticipant>>
      getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  });

  Future<Either<Failure, List<VotingSessionParticipant>>>
      getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  });
}

//* Implementation
class VotingSessionParticipantRepositoryImpl implements VotingSessionParticipantRepository {
  final VotingSessionParticipantService _votingSessionParticipantService;

  VotingSessionParticipantRepositoryImpl({
    required VotingSessionParticipantService votingSessionParticipantService,
  }) : _votingSessionParticipantService = votingSessionParticipantService;

  @override
  Future<Either<Failure, VotingSessionParticipant>> createVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  }) async {
    try {
      final result = await _votingSessionParticipantService.createVotingSessionParticipant(
          votingSessionParticipant: votingSessionParticipant);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingSessionParticipantById({required String id}) async {
    try {
      final result =
          await _votingSessionParticipantService.deleteVotingSessionParticipantById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipant>> getVotingSessionParticipantById({
    required String id,
  }) async {
    try {
      final result = await _votingSessionParticipantService.getVotingSessionParticipantById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipant>>
      getVotingSessionParticipantByVotingSessionIdAndParticipantId({
    required String votingSessionId,
    required String participantId,
  }) async {
    try {
      final result = await _votingSessionParticipantService
          .getVotingSessionParticipantByVotingSessionIdAndParticipantId(
              votingSessionId: votingSessionId,
              participantId: participantId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotingSessionParticipant>>>
      getVotingSessionParticipantsByVotingSessionId({
    required String votingSessionId,
  }) async {
    try {
      final result = await _votingSessionParticipantService
          .getVotingSessionParticipantsByVotingSessionId(votingSessionId: votingSessionId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingSessionParticipant>> updateVotingSessionParticipant({
    required VotingSessionParticipant votingSessionParticipant,
  }) async {
    try {
      final result = await _votingSessionParticipantService.updateVotingSessionParticipant(votingSessionParticipant: votingSessionParticipant);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
