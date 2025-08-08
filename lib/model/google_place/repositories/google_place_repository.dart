import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/google_place/entities/google_place.dart';
import 'package:swift_contest/model/google_place/entities/google_place_suggestion.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class GooglePlaceRepository {
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions({
    required String query,
  });

  Future<Either<Failure, GooglePlace>> fetchPlace({required String id});
}

//* Implementation
class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
  final SupabaseClient _supabase;

  GooglePlaceRepositoryImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions({
    required String query,
  }) async {
    return handleDatabaseCall(() async {
      if(query.isEmpty) {
        query = ' ';
      }
      final res = await _supabase.functions.invoke(
        'google-places-search-suggestions',
        body: {'query': query},
      );

      final jsonData = res.data['suggestions'];
      if (jsonData == null) {
        return Either.left(const ServerFailure('Suggestions not found'));
      }
      final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
        final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
        final placeId = placePrediction['placeId'] as String;
        final textData = placePrediction['text'] as Map<String, dynamic>;
        final address = textData['text'] as String;
        return GooglePlaceSuggestion(placeId: placeId, address: address);
      }).toList(growable: false);

      return Either.right(suggestionsList);
    },);
  }

  @override
  Future<Either<Failure, GooglePlace>> fetchPlace({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.functions.invoke('google-places-fetch-place', method: HttpMethod.get, body: {'id': id});
      return Either.right(GooglePlace.fromJson(res.data));
    },);
  }

// final String _apiKey;
// final String _baseUrl = 'https://places.googleapis.com/v1';
//
// GooglePlaceRepositoryImpl({required String apiKey}) : _apiKey = apiKey;
//
// @override
// Future<Either<Failure, GooglePlace>> fetchPlace({required String id}) async {
//   final uri = Uri.parse('$_baseUrl/places/$id');
//   final headers = {
//     'Content-Type': 'application/json',
//     'X-Goog-Api-Key': _apiKey,
//     'X-Goog-FieldMask': 'id,location,formattedAddress,shortFormattedAddress'
//   };
//
//   // Usa l'helper per la chiamata API
//   final result = await _handleApiCall(() => http.get(uri, headers: headers));
//
//   // Mappa il risultato di successo
//   return result.map((responseBody) {
//     final jsonData = json.decode(responseBody);
//     return GooglePlace.fromJson(jsonData);
//   });
// }
//
// @override
// Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions(
//     {required String query}) async {
//   if (query.trim().isEmpty) {
//     return Either.right([]);
//   }
//
//   final uri = Uri.parse('$_baseUrl/places:autocomplete');
//   final headers = {
//     'Content-Type': 'application/json',
//     'X-Goog-Api-Key': _apiKey,
//   };
//   final body = json.encode({'input': query});
//
//   // Usa l'helper per la chiamata API
//   final result = await _handleApiCall(() => http.post(uri, headers: headers, body: body));
//
//   // Mappa il risultato di successo
//   return result.map((responseBody) {
//     final jsonData = json.decode(responseBody)['suggestions'];
//     if (jsonData == null) {
//       // Questo è un caso di successo ma con dati malformati,
//       // che possiamo trattare come un errore del server.
//       throw Exception('Suggestions key not found in response');
//     }
//     final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
//       final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
//       final placeId = placePrediction['placeId'] as String;
//       final textData = placePrediction['text'] as Map<String, dynamic>;
//       final address = textData['text'] as String;
//       return GooglePlaceSuggestion(placeId: placeId, address: address);
//     }).toList(growable: false);
//
//     return suggestionsList;
//   });
// }
//
// /// Helper privato per centralizzare la gestione degli errori delle chiamate HTTP.
// Future<Either<Failure, String>> _handleApiCall(Future<http.Response> Function() apiCall) async {
//   try {
//     final response = await apiCall();
//
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       return Either.right(response.body);
//     } else {
//       // Qualsiasi status code non di successo è un errore del server.
//       return Either.left(
//           ServerFailure('API request failed with status code: ${response.statusCode}'));
//     }
//   } on SocketException {
//     // Errore di rete
//     return Either.left(const NetworkFailure());
//   } catch (e) {
//     // Qualsiasi altra eccezione (es. parsing JSON fallito nel map)
//     // è un errore inaspettato del server o del client.
//     return Either.left(const ServerFailure('An unexpected error occurred.'));
//   }
// }
}
