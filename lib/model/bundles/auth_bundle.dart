import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';

class AuthBundle extends Equatable {
  final User user;
  final Profile profile;

  const AuthBundle({required this.user, required this.profile});

  factory AuthBundle.fromRpcJson(Map<String, dynamic> json) {
    return AuthBundle(
        user: User.fromJson(json['m_user']), profile: Profile.fromJson(json['profile']));
  }

  factory AuthBundle.fromJson(Map<String, dynamic> json) {
    return AuthBundle(
        user: User.fromJson(json['user']), profile: Profile.fromJson(json['profile']));
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'profile': profile.toJson(),
    };
  }

  AuthBundle copyWith({
    User? user,
    Profile? profile,
  }) {
    return AuthBundle(
      user: user ?? this.user,
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object?> get props => [user, profile];
}
