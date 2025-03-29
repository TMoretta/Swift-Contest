import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/services/profile_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class ProfileRepository {
  Future<Either<Failure, Profile>> getCurrentProfile();

  Future<Either<Failure, List<Profile>>> getAllProfiles();

  Future<Either<Failure, Profile>> getProfileById({required String id});

  Future<Either<Failure, Profile>> updateProfileById({
    required String id,
    String? firstName,
    String? lastName,
    bool? isAlive,
  });
}

//* Implementation
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl({required ProfileService profileService})
      : _profileService = profileService;

  @override
  Future<Either<Failure, Profile>> getCurrentProfile() async {
    try {
      final res = await _profileService.getCurrentProfile();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Profile>>> getAllProfiles() async {
    try {
      final res = await _profileService.getAllProfiles();
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfileById({required String id}) async {
    try {
      final res = await _profileService.getProfileById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> updateProfileById({
    required String id,
    String? firstName,
    String? lastName,
    bool? isAlive,
  }) async {
    try {
      final res = await _profileService.updateProfileById(
        id: id,
        firstName: firstName,
        lastName: lastName,
        isAlive: isAlive,
      );
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
