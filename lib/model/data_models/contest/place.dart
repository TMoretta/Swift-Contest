class Place {
  final String address;
  final double lat;
  final double lon;

  Place({
    required this.address,
    required this.lat,
    required this.lon,
  });

  factory Place.fromJson(Map<String, dynamic> map) {
    return Place(
      address: map['address'] as String,
      lat: map['lat'] as double,
      lon: map['lon'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'lat': lat,
      'lon': lon,
    };
  }
}
