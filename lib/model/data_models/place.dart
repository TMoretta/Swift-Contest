import 'package:equatable/equatable.dart';

class Place extends Equatable {
  final String id;
  final DateTime createdAt;
  final String address;
  final double lat;
  final double lon;

  const Place({
    required this.id,
    required this.createdAt,
    required this.address,
    required this.lat,
    required this.lon,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      address: json['address'] as String,
      lat: json['lat'] as double,
      lon: json['lon'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'address': address,
      'lat': lat,
      'lon': lon,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_address': address,
      'p_lat': lat,
      'p_lon': lon,
    };
  }

  Place copyWith({
    String? id,
    DateTime? createdAt,
    String? address,
    double? lat,
    double? lon,
  }) {
    return Place(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  List<Object?> get props => [id, createdAt, address, lat, lon];
}
