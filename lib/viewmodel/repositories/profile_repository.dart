import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/services/profile_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ProfileRepository {
  Future<Either<Failure, Profile>> getCurrentProfile();

  Future<Either<Failure, Profile>> updateProfile(
      {required Profile profile,});

  Future<Either<Failure, Unit>> deleteProfileById({required String id});

  Future<Either<Failure, List<Profile>>> getAllProfiles();

  Future<Either<Failure, Profile>> getProfileById({required String id});
}

//* Implementation
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<Either<Failure, Unit>> deleteProfileById({required String id}) async {
    try {
      final result = await _profileService.deleteProfileById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getAllProfiles() async {
    try {
      final result = await _profileService.getAllProfiles();
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> getCurrentProfile() async {
    try {
      final result = await _profileService.getCurrentProfile();
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfileById({required String id}) async {
    try {
      final result = await _profileService.getProfileById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfile({
    required Profile profile,
  }) async {
    try {
      final result = await _profileService.updateProfile(profile: profile);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
