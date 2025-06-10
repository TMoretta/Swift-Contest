import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class ProfileRepository {
  Future<Either<Failure, Profile?>> getCurrentProfile();

  Future<Either<Failure, Profile>> updateProfile({required Profile profile});

  Future<Either<Failure, Profile>> deleteProfileById({required String id});

  Future<Either<Failure, List<Profile>>> getAllProfiles();

  Future<Either<Failure, Profile?>> getProfileById({required String id});
}

//* Implementation
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  Session? get currentSession => _supabase.auth.currentSession;

  @override
  Future<Either<Failure, Profile?>> getCurrentProfile() async {
    if (currentSession == null) {
      return right(null);
    }
    return await getProfileById(id: currentSession!.user.id);
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({required Profile profile}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_profile', params: {'p_profile': profile.toJson()});
      return right(Profile.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> deleteProfileById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_profile_by_id', params: {'p_id': id});
      return right(Profile.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getAllProfiles() async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc('get_all_profiles');
      return right(res.map((e) => Profile.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile?>> getProfileById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_profile_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(Profile.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
