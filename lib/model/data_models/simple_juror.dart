import 'package:equatable/equatable.dart';

class SimpleJuror extends Equatable {
  final String id;
  final DateTime createdAt;
  final String fullName;

  const SimpleJuror({
    required this.id,
    required this.createdAt,
    required this.fullName,
  });

  factory SimpleJuror.fromJson(Map<String, dynamic> json) {
    return SimpleJuror(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      fullName: json['full_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'full_name': fullName,
    };
  }

  SimpleJuror copyWith({
    String? id,
    DateTime? createdAt,
    String? fullName,
  }) {
    return SimpleJuror(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        fullName,
      ];
}

class SimpleJurorModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? fullName;

  const SimpleJurorModel({
    this.id,
    this.createdAt,
    this.fullName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'full_name': fullName,
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        fullName,
      ];
}
