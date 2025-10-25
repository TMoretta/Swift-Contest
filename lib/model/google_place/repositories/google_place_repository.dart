import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/google_place/entities/google_place.dart';
import 'package:swift_contest/model/google_place/entities/google_place_suggestion.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class GooglePlaceRepository {
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions({
    required String query,
  });

  Future<Either<Failure, GooglePlace>> fetchPlace({required String placeId});
}

//* Implementation
class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
  final SupabaseClient _supabase;

  GooglePlaceRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions({
    required String query,
  }) async {
    return handleBackendCall(
      () async {
        if (query.isEmpty) {
          return Either.right([]);
        }
        final res = await _supabase.functions.invoke(
          'google-places-search-suggestions',
          body: {'query': query},
        );

        // The Edge Function now returns a clean list of suggestions, simplifying the client.
        if (res.data == null) {
          return Either.left(const ServerFailure('Received no data from server.'));
        }
        final suggestionsList = (res.data as List<dynamic>)
            .map((suggestion) => GooglePlaceSuggestion(
                  placeId: suggestion['placeId'],
                  address: suggestion['address'],
                ))
            .toList(growable: false);
        return Either.right(suggestionsList);
      },
    );
  }

  @override
  Future<Either<Failure, GooglePlace>> fetchPlace({required String placeId}) async {
    return handleBackendCall(
      () async {
        final res = await _supabase.functions
            .invoke('google-places-fetch-place', body: {'place_id': placeId});
        return Either.right(GooglePlace.fromJson(res.data));
      },
    );
  }
}
