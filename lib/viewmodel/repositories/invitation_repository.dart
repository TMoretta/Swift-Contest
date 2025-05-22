import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/model/services/invitation_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class InvitationRepository {
  Future<Either<Failure, Invitation>> createInvitation({
    required Invitation invitation,
  });

  Future<Either<Failure, Invitation>> updateInvitation({
    required Invitation invitation,
  });

  Future<Either<Failure, Unit>> deleteInvitationById({required String id});

  Future<Either<Failure, Invitation>> getInvitationById({required String id});

  Future<Either<Failure, Invitation>> getInvitationByContestIdAndToken({
    required String contestId,
    required String token,
  });

  Future<Either<Failure, List<Invitation>>> getInvitationsByContestId({
    required String contestId,
  });

  Future<Either<Failure, List<Invitation>>> getInvitationsByContestIdAndMemberRole({
    required String contestId,
    required MemberRole memberRole,
  });
}

//* Implementation
class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationService _invitationService;

  InvitationRepositoryImpl({required InvitationService invitationService})
      : _invitationService = invitationService;

  @override
  Future<Either<Failure, Invitation>> createInvitation({
    required Invitation invitation,
  }) async {
    try {
      final result = await _invitationService.createInvitation(invitation: invitation);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvitationById({
    required String id,
  }) async {
    try {
      final result = await _invitationService.deleteInvitationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Invitation>> getInvitationByContestIdAndToken({
    required String contestId,
    required String token,
  }) async {
    try {
      final result = await _invitationService.getInvitationByContestIdAndToken(
          contestId: contestId, token: token);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Invitation>> getInvitationById({
    required String id,
  }) async {
    try {
      final result = await _invitationService.getInvitationById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Invitation>>> getInvitationsByContestId({
    required String contestId,
  }) async {
    try {
      final result = await _invitationService.getInvitationsByContestId(contestId: contestId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Invitation>> updateInvitation({
    required Invitation invitation,
  }) async {
    try {
      final result = await _invitationService.updateInvitation(invitation: invitation);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Invitation>>> getInvitationsByContestIdAndMemberRole({
    required String contestId,
    required MemberRole memberRole,
  }) async {
    try {
      final result = await _invitationService.getInvitationsByContestIdAndMemberRole(
          contestId: contestId, memberRole: memberRole);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
