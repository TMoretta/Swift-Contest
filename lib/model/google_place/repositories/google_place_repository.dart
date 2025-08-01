import 'dart:convert';
import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:swift_contest/model/google_place/entities/google_place.dart';
import 'package:swift_contest/model/google_place/entities/google_place_suggestion.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class GooglePlaceRepository {
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions(
      {required String query});

  Future<Either<Failure, GooglePlace>> fetchPlace({required String id});
}

//* Implementation
class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
  final String _apiKey;
  final String _baseUrl = 'https://places.googleapis.com/v1';

  GooglePlaceRepositoryImpl({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<Either<Failure, GooglePlace>> fetchPlace({required String id}) async {
    final uri = Uri.parse('$_baseUrl/places/$id');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'id,location,formattedAddress,shortFormattedAddress'
    };

    // Usa l'helper per la chiamata API
    final result = await _handleApiCall(() => http.get(uri, headers: headers));

    // Mappa il risultato di successo
    return result.map((responseBody) {
      final jsonData = json.decode(responseBody);
      return GooglePlace.fromJson(jsonData);
    });
  }

  @override
  Future<Either<Failure, List<GooglePlaceSuggestion>>> searchPlaceSuggestions(
      {required String query}) async {
    if (query.trim().isEmpty) {
      return Either.right([]);
    }

    final uri = Uri.parse('$_baseUrl/places:autocomplete');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
    };
    final body = json.encode({'input': query});

    // Usa l'helper per la chiamata API
    final result = await _handleApiCall(() => http.post(uri, headers: headers, body: body));

    // Mappa il risultato di successo
    return result.map((responseBody) {
      final jsonData = json.decode(responseBody)['suggestions'];
      if (jsonData == null) {
        // Questo è un caso di successo ma con dati malformati,
        // che possiamo trattare come un errore del server.
        throw Exception('Suggestions key not found in response');
      }
      final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
        final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
        final placeId = placePrediction['placeId'] as String;
        final textData = placePrediction['text'] as Map<String, dynamic>;
        final address = textData['text'] as String;
        return GooglePlaceSuggestion(placeId: placeId, address: address);
      }).toList(growable: false);

      return suggestionsList;
    });
  }

  /// Helper privato per centralizzare la gestione degli errori delle chiamate HTTP.
  Future<Either<Failure, String>> _handleApiCall(
      Future<http.Response> Function() apiCall) async {
    try {
      final response = await apiCall();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Either.right(response.body);
      } else {
        // Qualsiasi status code non di successo è un errore del server.
        return Either.left(ServerFailure(
            'API request failed with status code: ${response.statusCode}'));
      }
    } on SocketException {
      // Errore di rete
      return Either.left(const NetworkFailure());
    } catch (e) {
      // Qualsiasi altra eccezione (es. parsing JSON fallito nel map)
      // è un errore inaspettato del server o del client.
      return Either.left(const ServerFailure('An unexpected error occurred.'));
    }
  }
}

// import 'package:swift_contest/utils/failures/failures.dart';
//
// //* Interface
// abstract interface class GooglePlaceRepository {
//   Future<Either<Failure,List<GooglePlaceSuggestion>>> searchPlaceSuggestions({required String query});
//
//   Future<Either<Failure,GooglePlace>> fetchPlace({required String id});
// }
//
// //* Implementation
// class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
//   final String _apiKey;
//
//   GooglePlaceRepositoryImpl({required String apiKey}) : _apiKey = apiKey;
//
//   @override
//   Future<Either<Failure,GooglePlace>> fetchPlace({required String id}) async {
//     try {
//       var headers = {
//         'Content-Type': 'application/json',
//         'X-Goog-Api-Key': _apiKey,
//         'X-Goog-FieldMask': 'id,location,formattedAddress,shortFormattedAddress'
//       };
//       var request = http.Request('GET', Uri.parse('https://places.googleapis.com/v1/places/$id'));
//       request.headers.addAll(headers);
//
//       http.StreamedResponse response = await request.send();
//       String result = await response.stream.bytesToString();
//       if (response.statusCode != 200) {
//         return Either.left(Failure('Failed to fetch place'));
//       }
//       final jsonData = json.decode(result);
//       final place = GooglePlace.fromJson(jsonData);
//
//       return Either.right(place);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//
//   }
//
//   @override
//   Future<Either<Failure,List<GooglePlaceSuggestion>>> searchPlaceSuggestions({required String query}) async {
//     if(query.trim().isEmpty) {
//       return Either.right([]);
//     }
//     try {
//       var headers = {
//         'Content-Type': 'application/json',
//         'X-Goog-Api-Key': _apiKey,
//         'X-Goog-FieldMask':
//         'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text'
//       };
//       var request = http.Request('POST', Uri.parse('https://places.googleapis.com/v1/places:autocomplete'));
//       request.headers.addAll(headers);
//       request.body = json.encode({'input': query});
//
//       http.StreamedResponse response = await request.send();
//       String result = await response.stream.bytesToString();
//       if (response.statusCode != 200) {
//         return Either.left(Failure('Failed to fetch suggestions'));
//       }
//
//       final jsonData = await json.decode(result)['suggestions'];
//       if(jsonData == null) {
//         return Either.left(Failure('Failed to fetch suggestions'));
//       }
//       final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
//         final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
//         final placeId = placePrediction['placeId'] as String;
//         final textData = placePrediction['text'] as Map<String, dynamic>;
//         final address = textData['text'] as String;
//         return GooglePlaceSuggestion(placeId: placeId, address: address);
//       }).toList(growable: false);
//
//       return Either.right(suggestionsList);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
// }
