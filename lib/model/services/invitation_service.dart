import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/member_role.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

abstract interface class InvitationService {
  Future<Invitation> createInvitation({required Invitation invitation});

  Future<Invitation> updateInvitationById({
    required String id,
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

class InvitationServiceImpl implements InvitationService {
  final SupabaseClient _supabase;

  InvitationServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Invitation> createInvitation({required Invitation invitation}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('invitations')
          .insert(invitation.toJson())
          .select();
      return Invitation.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteInvitationById({required String id}) async {
    try {
      await _supabase.from('invitations').delete().eq('id', id);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('invitations')
          .select()
          .eq('contest_id', contestId)
          .eq('token', token);
      return Invitation.fromJson(results[0]);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Invitation> getInvitationById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results =
          await _supabase.from('invitations').select().eq('id', id);
      return Invitation.fromJson(results[0]);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('invitations')
          .select()
          .eq('contest_id', contestId);
      return results.map((e) => Invitation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Invitation> updateInvitationById({
    required String id,
    required Invitation invitation,
  }) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('invitations')
          .update(invitation.toJson())
          .eq('id', id)
          .select();
      return Invitation.fromJson(results[0]);
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
      final List<Map<String, dynamic>> results = await _supabase
          .from('invitations')
          .select()
          .eq('contest_id', contestId)
          .eq('member_role', memberRole.name);
      return results.map((e) => Invitation.fromJson(e)).toList(growable: false);
    } on SafeException {
      rethrow;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
