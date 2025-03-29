import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/model/google_place_models/google_place_suggestion.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class GooglePlaceService {
  Future<List<GooglePlaceSuggestion>> searchPlaceSuggestions({required String query});

  Future<GooglePlace> fetchPlace({required String id});
}

//* Implementation
class GooglePlaceServiceImpl implements GooglePlaceService {
  final String _apiKey;

  GooglePlaceServiceImpl({required String apiKey}) : _apiKey = apiKey;

  @override
  Future<GooglePlace> fetchPlace({required String id}) async {
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
        throw CustomException(message: 'Failed to fetch place: $result');
      }
      final jsonData = json.decode(result);
      final place = GooglePlace.fromJson(jsonData);

      return place;
    } catch (e) {
      throw CustomException(message: e.toString());
    }

  }

  @override
  Future<List<GooglePlaceSuggestion>> searchPlaceSuggestions({required String query}) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask':
        'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text'
      };
      var request =
      http.Request('POST', Uri.parse('https://places.googleapis.com/v1/places:autocomplete'));
      request.headers.addAll(headers);
      request.body = json.encode({'input': query});

      http.StreamedResponse response = await request.send();
      String result = await response.stream.bytesToString();
      if (response.statusCode != 200) {
        throw CustomException(message: 'Failed to fetch suggestions: $result');
      }

      final jsonData = json.decode(result)['suggestions'];
      final suggestionsList = (jsonData as List<dynamic>).map((suggestion) {
        final placePrediction = suggestion['placePrediction'] as Map<String, dynamic>;
        final placeId = placePrediction['placeId'] as String;
        final textData = placePrediction['text'] as Map<String, dynamic>;
        final address = textData['text'] as String;
        return GooglePlaceSuggestion(placeId: placeId, address: address);
      }).toList(growable: false);

      return suggestionsList;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}

// abstract interface class GooglePlaceService {
//   Future<List<GooglePlaceSuggestion>> searchPlaceSuggestions({required String query});
//
//   Future<GooglePlace> fetchPlace({required String id});
// }
//
// class GooglePlaceServiceImpl implements GooglePlaceService {
//   final FlutterGooglePlacesSdk _googlePlacesSdk;
//
//   GooglePlaceServiceImpl({required FlutterGooglePlacesSdk googlePlacesSdk})
//       : _googlePlacesSdk = googlePlacesSdk;
//
//   @override
//   Future<GooglePlace> fetchPlace({required String id}) async {
//     try {
//       final res = await _googlePlacesSdk.fetchPlace(id, fields: [
//         PlaceField.Name,
//         PlaceField.Address,
//         PlaceField.Location,
//       ]);
//       final address = res.place?.address;
//       final latLon = res.place?.latLng;
//       final lat = latLon?.lat;
//       final lon = latLon?.lng;
//       if (address != null && lat != null && lon != null) {
//         return GooglePlace(id: id, address: address, lat: lat, lon: lon);
//       }
//       throw CustomException(message: 'Some information about place is null');
//     } catch (e) {
//       throw CustomException(message: e.toString());
//     }
//   }
//
//   @override
//   Future<List<GooglePlaceSuggestion>> searchPlaceSuggestions({required String query}) async {
//     try {
//       final res = await _googlePlacesSdk.findAutocompletePredictions(query);
//       final predictions = res.predictions;
//       return predictions
//           .map((prediction) =>
//               GooglePlaceSuggestion(placeId: prediction.placeId, address: prediction.fullText))
//           .toList();
//     } catch (e) {
//       throw CustomException(message: e.toString());
//     }
//   }
// }