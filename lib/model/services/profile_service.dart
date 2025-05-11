import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart' as my;
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';

//* Interface
abstract interface class ProfileService {
  Future<Profile> getCurrentProfile();

  Future<Profile> updateProfileById({required String id, required Profile profile});

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
      final user = my.User.fromJson(session.user.toJson());
      return await getProfileById(id: user.id);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Profile> updateProfileById({required String id, required Profile profile}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase
          .from('profiles')
          .update(profile.toJson())
          .eq('id', id)
          .select();
      return Profile.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Unit> deleteProfileById({required String id}) async {
    try {
      await _supabase.from('profiles').delete().eq('id', id);
      return unit;
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    try {
      final List<Map<String, dynamic>> results = await _supabase.from('profiles').select();
      return results.map((e) => Profile.fromJson(e)).toList(growable: false);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

  @override
  Future<Profile> getProfileById({required String id}) async {
    try {
      final List<Map<String, dynamic>> results = await _supabase.from('profiles').select().eq('id', id);
      return Profile.fromJson(results[0]);
    } catch (e) {
      throw UnsafeException(message: e.toString());
    }
  }

}
