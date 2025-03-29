class GooglePlaceSuggestion {
  final String placeId;
  final String address;

  GooglePlaceSuggestion({
    required this.placeId,
    required this.address,
  });

  factory GooglePlaceSuggestion.fromJson(Map<String, dynamic> map) {
    return GooglePlaceSuggestion(
      placeId: map['place_id'] as String,
      address: map['description'] as String,
    );
  }
}
