import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class InvitationService {
  Future<Invitation> createInvitation({required Invitation invitation});

  Future<Invitation> updateInvitation({
    required Invitation invitation,
  });

  Future<Unit> deleteInvitationById({required String id});

  Future<Invitation> getInvitationById({required String id});

  Future<Invitation> getInvitationByContestIdAndToken({
    required String contestId,
    required String token,
  });

  Future<List<Invitation>> getInvitationsByContestId({
    required String contestId,
  });

  Future<List<Invitation>> getInvitationsByContestIdAndMemberRole({
    required String contestId,
    required MemberRole memberRole,
  });
}

//* Implementation
class InvitationServiceImpl implements InvitationService {
  final SupabaseClient _supabase;

  InvitationServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Invitation> createInvitation({required Invitation invitation}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('create_invitation', params: invitation.toRpcJson());
      if (res.isEmpty) {
        throw SafeException(message: 'Invitation creation failed');
      }
      return Invitation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteInvitationById({required String id}) async {
    try {
      await _supabase.rpc('delete_invitation_by_id', params: {'p_id': id});
      return unit;
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Invitation> getInvitationByContestIdAndToken({
    required String contestId,
    required String token,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_invitation_by_contest_id_and_token',
          params: {'p_contest_id': contestId, 'p_token': token});
      if (res.isEmpty) {
        throw SafeException(message: 'No invitation found');
      }
      return Invitation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Invitation> getInvitationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_invitation_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'No invitation found');
      }
      return Invitation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Invitation>> getInvitationsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_invitations_by_contest_id',params: {'p_contest_id':contestId});
      return res.map((e) => Invitation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Invitation> updateInvitation({
    required Invitation invitation,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('update_invitation',params: invitation.toRpcJson());
      if(res.isEmpty) {
        throw SafeException(message: 'Invitation update failed');
      }
      return Invitation.fromJson(res[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Invitation>> getInvitationsByContestIdAndMemberRole({
    required String contestId,
    required MemberRole memberRole,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_invitations_by_contest_id_and_member_role',params: {'p_contest_id':contestId,'p_member_role':memberRole});
      return res.map((e) => Invitation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
