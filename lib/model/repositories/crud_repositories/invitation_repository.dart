import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class InvitationRepository {
  Future<Either<Failure, Invitation>> createInvitation({required Invitation invitation});

  Future<Either<Failure, Invitation>> updateInvitation({
    required Invitation invitation,
  });

  Future<Either<Failure, Invitation>> deleteInvitationById({
    required String id,
  });

  Future<Either<Failure, Invitation?>> getInvitationById({required String id});

  Future<Either<Failure, Invitation?>> getInvitationByContestIdAndToken({
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
  final SupabaseClient _supabase;

  InvitationRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, Invitation>> createInvitation({required Invitation invitation}) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('create_invitation', params: {'p_invitation': invitation.toJson()});
      return right(Invitation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Invitation>> updateInvitation({
    required Invitation invitation,
  }) async {
    try {
      final Map<String, dynamic> res = await _supabase.rpc('update_invitation', params: {'p_invitation': invitation.toJson()});
      return right(Invitation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Invitation>> deleteInvitationById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_invitation_by_id', params: {'p_id': id});
      return right(Invitation.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Invitation?>> getInvitationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_invitation_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Invitation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Invitation?>> getInvitationByContestIdAndToken({
    required String contestId,
    required String token,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_invitation_by_contest_id_and_token',
          params: {'p_contest_id': contestId, 'p_token': token});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Invitation.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Invitation>>> getInvitationsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_invitations_by_contest_id', params: {'p_contest_id': contestId});
      return right(res.map((e) => Invitation.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Invitation>>> getInvitationsByContestIdAndMemberRole({
    required String contestId,
    required MemberRole memberRole,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_invitations_by_contest_id_and_member_role',
          params: {'p_contest_id': contestId, 'p_member_role': memberRole.name});
      return right(res.map((e) => Invitation.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
