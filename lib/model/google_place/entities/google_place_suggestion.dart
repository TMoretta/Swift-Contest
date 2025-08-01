import 'package:equatable/equatable.dart';

class GooglePlaceSuggestion extends Equatable {
  final String placeId;
  final String address;

  const GooglePlaceSuggestion({
    required this.placeId,
    required this.address,
  });

  factory GooglePlaceSuggestion.fromJson(Map<String, dynamic> map) {
    return GooglePlaceSuggestion(
      placeId: map['place_id'] as String,
      address: map['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'description': address,
    };
  }

  GooglePlaceSuggestion copyWith({
    String? placeId,
    String? address,
  }) {
    return GooglePlaceSuggestion(
      placeId: placeId ?? this.placeId,
      address: address ?? this.address,
    );
  }


  @override
  List<Object?> get props => [placeId, address];
}
