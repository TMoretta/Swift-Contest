import 'package:equatable/equatable.dart';

class GooglePlace extends Equatable {
  final String id;
  final String address;
  final String shortAddress;
  final double lat;
  final double lon;

  const GooglePlace({
    required this.id,
    required this.address,
    required this.shortAddress,
    required this.lat,
    required this.lon,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> map) {
    return GooglePlace(
      id: map['id'] as String,
      address: map['formattedAddress'] as String,
      shortAddress: map['shortFormattedAddress'] as String,
      lat: (map['location'])['latitude'] as double,
      lon: (map['location'])['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'shortAddress': shortAddress,
      'lat': lat,
      'lon': lon,
    };
  }

  GooglePlace copyWith({
    String? id,
    String? address,
    String? shortAddress,
    double? lat,
    double? lon,
  }) {
    return GooglePlace(
      id: id ?? this.id,
      address: address ?? this.address,
      shortAddress: shortAddress ?? this.shortAddress,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  List<Object?> get props => [
        id,
        address,
        shortAddress,
        lat,
        lon,
      ];
}
