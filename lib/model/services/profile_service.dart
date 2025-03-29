import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/user/user.dart' as my;
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ProfileService {
  Session? get currentSession;

  Future<Profile> getCurrentProfile();

  Future<List<Profile>> getAllProfiles();

  Future<Profile> getProfileById({required String id});

  Future<Profile> updateProfileById({
    required String id,
    String? firstName,
    String? lastName,
    bool? isAlive,
  });
}

//* Implementation
class ProfileServiceImpl implements ProfileService {
  final SupabaseClient _supabase;

  ProfileServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Future<Profile> getCurrentProfile() async {
    try {
      final session = currentSession;
      if (session == null) {
        throw CustomException(message: 'No valid session');
      }
      final user = my.User.fromJson(session.user.toJson());
      return await getProfileById(id: user.id);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<List<Profile>> getAllProfiles() async {
    try {
      final List<Map<String, dynamic>> profilesMaps = await _supabase.rpc('get_all_profiles');
      return profilesMaps.map((profileMap) => Profile.fromJson(profileMap)).toList(growable: false);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Profile> getProfileById({required String id}) async {
    try {
      final Map<String, dynamic> profileMap =
          await _supabase.rpc('get_profile_by_id', params: {'p_id': id});
      return Profile.fromJson(profileMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Profile> updateProfileById({
    required String id,
    String? firstName,
    String? lastName,
    bool? isAlive,
  }) async {
    try {
      final Map<String, dynamic> profileMap = await _supabase.rpc('update_profile_by_id', params: {
        'p_id': id,
        'p_first_name': firstName,
        'p_last_name': lastName,
        'p_is_alive': isAlive,
      });
      return Profile.fromJson(profileMap);
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
