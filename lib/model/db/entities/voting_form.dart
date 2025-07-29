import 'package:equatable/equatable.dart';

class VotingForm extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? header;
  final String? footer;

  const VotingForm({
    required this.id,
    required this.createdAt,
    required this.header,
    required this.footer,
  });

  factory VotingForm.fromJson(Map<String, dynamic> json) {
    return VotingForm(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      header: json['header'] as String?,
      footer: json['footer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      'header': header,
      'footer': footer,
    };
  }

  VotingForm copyWith({
    String? id,
    DateTime? createdAt,
    String? header,
    String? footer,
  }) {
    return VotingForm(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      header: header ?? this.header,
      footer: footer ?? this.footer,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        header,
        footer,
      ];
}
