import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/utils/exceptions/safe_exception.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ProfileService {
  Future<Profile> getCurrentProfile();

  Future<Profile> updateProfile({required Profile profile});

  Future<Unit> deleteProfileById({required String id});

  Future<List<Profile>> getAllProfiles();

  Future<Profile> getProfileById({required String id});
}

//* Implementation
class ProfileServiceImpl implements ProfileService {
  final SupabaseClient _supabase;

  ProfileServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Future<Profile> getCurrentProfile() async {
    try {
      final session = currentSession;
      if (session == null) {
        throw UnsafeException(message: 'No valid session');
      }
      final userId = session.user.id;
      return await getProfileById(id: userId);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Profile> updateProfile({required Profile profile}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('update_profile', params: profile.toRpcJson());
      if(res.isEmpty) {
        throw SafeException(message: 'Profile update failed');
      }
      return Profile.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteProfileById({required String id}) async {
    try {
      await _supabase.rpc('delete_profile_by_id',params: {'p_id': id});
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    try {
      final List<Map<String, dynamic>> results = await _supabase.rpc('get_all_profiles');
      return results.map((e) => Profile.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Profile> getProfileById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_profile_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        throw SafeException(message: 'Profile not found');
      }
      return Profile.fromJson(res[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }
}
