import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/bundles/account_bundle.dart';
import 'package:swift_contest/model/database/entities/juration.dart';

final class JurationBundle extends Equatable {
  final Juration juration;
  final AccountBundle jurorBundle;

  const JurationBundle({
    required this.juration,
    required this.jurorBundle,
  });

  factory JurationBundle.fromJson(Map<String, dynamic> json) {
    return JurationBundle(
      juration: Juration.fromJson(json['juration']),
      jurorBundle: AccountBundle.fromJson(json['juror_bundle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'juration': juration.toJson(),
      'juror_bundle': jurorBundle.toJson(),
    };
  }

  JurationBundle copyWith({
    Juration? juration,
    AccountBundle? jurorBundle,
  }) {
    return JurationBundle(
      juration: juration ?? this.juration,
      jurorBundle: jurorBundle ?? this.jurorBundle,
    );
  }

  @override
  List<Object?> get props => [juration, jurorBundle];
}
