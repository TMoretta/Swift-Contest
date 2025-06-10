import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/profile.dart';

final class JurationBundle extends Equatable {
  final Juration juration;
  final Juror juror;

  const JurationBundle({
    required this.juration,
    required this.juror,
  });

  factory JurationBundle.fromJson(Map<String, dynamic> json) {
    return JurationBundle(
      juration: Juration.fromJson(json['juration']),
      juror: Juror.fromJson(json['juror']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juration': juration.toJson(),
      'juror': juror.toJson(),
    };
  }

  JurationBundle copyWith({
    Juration? juration,
    Juror? juror,
  }) {
    return JurationBundle(
      juration: juration ?? this.juration,
      juror: juror ?? this.juror,
    );
  }

  @override
  List<Object?> get props => [juration, juror];
}
