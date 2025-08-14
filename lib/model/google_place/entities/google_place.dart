import 'package:equatable/equatable.dart';

class GooglePlace extends Equatable {
  final String id;
  final String address;
  final double lat;
  final double lon;

  const GooglePlace({
    required this.id,
    required this.address,
    required this.lat,
    required this.lon,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> json) {
    return GooglePlace(
      id: json['id'] as String,
      address: json['address'] as String,
      lat: json['lat'] as double,
      lon: json['lon']as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'lat': lat,
      'lon': lon,
    };
  }

  GooglePlace copyWith({
    String? id,
    String? address,
    double? lat,
    double? lon,
  }) {
    return GooglePlace(
      id: id ?? this.id,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  List<Object?> get props => [
    id,
    address,
    lat,
    lon,
  ];
}
