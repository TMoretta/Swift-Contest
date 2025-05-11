import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/juration.dart';
import 'package:swift_contest/model/data_models/profile.dart';

class JurationAndJuror extends Equatable {
  final Juration juration;
  final Juror? juror;

  const JurationAndJuror({required this.juration, required this.juror});

  factory JurationAndJuror.fromJson(Map<String, dynamic> map) {
    return JurationAndJuror(
      juration: Juration.fromJson(map['juration'] as Map<String, dynamic>),
      juror: map['juror'] != null ? Juror.fromJson(map['juror'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juration': juration.toJson(),
      'juror': juror?.toJson(),
    };
  }

  @override
  List<Object?> get props => [juration, juror];
}
