import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/model/services/google_place_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class GooglePlaceRepository {
  Future<Either<Failure,GooglePlace>> fetchPlace({required String id});
  Future<Either<Failure,List<GooglePlaceSuggestion>>> searchPlaceSuggestions({required String query});
}

//* Implementation
class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
  final GooglePlaceService _googlePlaceService;

  GooglePlaceRepositoryImpl({required GooglePlaceService googlePlaceService})
      : _googlePlaceService = googlePlaceService;

  @override
  Future<Either<Failure, GooglePlace>> fetchPlace({required String id}) async {
    try {
      final place = await _googlePlaceService.fetchPlace(id: id);
      return right(place);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions(
      {required String query,}) async {
    try {
      final suggestions = await _googlePlaceService.searchPlaceSuggestions(query: query);
      return right(suggestions);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
