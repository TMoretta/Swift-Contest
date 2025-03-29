// import 'dart:math';
//
// import 'package:swift_contest/model/data_models/contest/form_type.dart';
//
// class WorkForm {
//   final String id;
//   final String name;
//   final FormType type;
//   final int? minValue;
//   final int? maxValue;
//
//   WorkForm({
//     required this.id,
//     required this.name,
//     required this.type,
//     this.minValue,
//     this.maxValue,
//   });
//
//   factory WorkForm.fromJson(Map<String, dynamic> map) {
//     return WorkForm(
//       id: map['id'] as String,
//       name: map['name'] as String,
//       type: FormType.values.byName(map['type']),
//       minValue: map['min_value'] as int?,
//       maxValue: map['max_value'] as int?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'type': type.name,
//       'min_value' : minValue,
//       'max_value' : maxValue,
//     };
//   }
// }
