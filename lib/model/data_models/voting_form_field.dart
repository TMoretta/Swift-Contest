import 'package:equatable/equatable.dart';

class VotingFormField extends Equatable {
  final String id;
  final DateTime createdAt;
  final String votingFormId;
  final String name;
  final int orderIndex;
  final double minValue;
  final double maxValue;

  const VotingFormField({
    required this.id,
    required this.createdAt,
    required this.votingFormId,
    required this.name,
    required this.orderIndex,
    required this.minValue,
    required this.maxValue,
  });

  factory VotingFormField.fromJson(Map<String, dynamic> json) {
    return VotingFormField(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      votingFormId: json['voting_form_id'] as String,
      name: json['name'] as String,
      orderIndex: json['order_index'] as int,
      minValue: json['min_value'] as double,
      maxValue: json['max_value'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'voting_form_id': votingFormId,
      'name': name,
      'order_index': orderIndex,
      'min_value': minValue,
      'max_value': maxValue,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_created_at': createdAt.toUtc().toIso8601String(),
      'p_voting_form_id': votingFormId,
      'p_name': name,
      'p_order_index': orderIndex,
      'p_min_value': minValue,
      'p_max_value': maxValue,
    };
  }

  VotingFormField copyWith({
    String? id,
    DateTime? createdAt,
    String? votingFormId,
    String? name,
    int? orderIndex,
    double? minValue,
    double? maxValue,
  }) {
    return VotingFormField(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      name: name ?? this.name,
      votingFormId: votingFormId ?? this.votingFormId,
      orderIndex: orderIndex ?? this.orderIndex,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        name,
        votingFormId,
        orderIndex,
        minValue,
        maxValue,
      ];
}

// class VotingFormFieldRaw {
//   final String name;
//   final int? minValue;
//   final int? maxValue;
//
//   VotingFormFieldRaw({
//     required this.name,
//     this.minValue,
//     this.maxValue,
//   });
//
//   factory VotingFormFieldRaw.fromJson(Map<String, dynamic> json) {
//     return VotingFormFieldRaw(
//       name: json['name'] as String,
//       minValue: json['min_value'] != null ? json['min_value'] as int : null,
//       maxValue: json['max_value'] != null ? json['max_value'] as int : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'min_value': minValue,
//       'max_value': maxValue,
//     };
//   }
// }
