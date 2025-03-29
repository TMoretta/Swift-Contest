import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';

class JurationAndJuror {
  final Juration juration;
  final Profile? juror;

  JurationAndJuror({required this.juration, required this.juror});

  factory JurationAndJuror.fromJson(Map<String, dynamic> map) {
    final jurorMap = map['juror'];
    return JurationAndJuror(
      juration: Juration.fromJson(map['juration'] as Map<String, dynamic>),
      juror: (jurorMap != null) ? Profile.fromJson(map['juror'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juration': juration.toJson(),
      'juror': juror?.toJson(),
    };
  }
}
