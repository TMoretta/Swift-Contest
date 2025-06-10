import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class GooglePlaceRepository {
  Future<Either<Failure,List<GooglePlaceSuggestion>>> searchPlaceSuggestions({required String query});

  Future<Either<Failure,GooglePlace>> fetchPlace({required String id});
}

//* Implementation
class GooglePlaceRepositoryImpl implements GooglePlaceRepository {
  final String _apiKey;

  GooglePlaceRepositoryImpl({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<Either<Failure,GooglePlace>> fetchPlace({required String id}) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'id,location,formattedAddress,shortFormattedAddress'
      };
      var request = http.Request('GET', Uri.parse('https://places.googleapis.com/v1/places/$id'));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String result = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        return left(Failure(message: 'Failed to fetch place'));
      }
      final jsonData = json.decode(result);
      final place = GooglePlace.fromJson(jsonData);

      return right(place);
    } catch (e) {
      return left(Failure());
    }

  }

  @override
  Future<Either<Failure,List<GooglePlaceSuggestion>>> searchPlaceSuggestions({required String query}) async {
    if(query.trim().isEmpty) {
      return right([]);
    }
    try {
      var headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
        'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text'
      };
      var request = http.Request('POST', Uri.parse('https://places.googleapis.com/v1/places:autocomplete'));
      request.headers.addAll(headers);
      request.body = json.encode({'input': query});

      http.StreamedResponse response = await request.send();
      String result = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        return left(Failure(message: 'Failed to fetch suggestions'));
      }

      final jsonData = await json.decode(result)['suggestions'];
      if(jsonData == null) {
        return left(Failure(message: 'Failed to fetch suggestions'));
      }
      final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
        final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
        final placeId = placePrediction['placeId'] as String;
        final textData = placePrediction['text'] as Map<String, dynamic>;
        final address = textData['text'] as String;
        return GooglePlaceSuggestion(placeId: placeId, address: address);
      }).toList(growable: false);

      return right(suggestionsList);
    } catch (e) {
      return left(Failure());
    }
  }
}
