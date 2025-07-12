import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';

class AuthBundle extends Equatable {
  final User user;
  final Profile profile;
  final List<Message> messages;

  const AuthBundle({
    required this.user,
    required this.profile,
    required this.messages,
  });

  factory AuthBundle.fromRpcJson(Map<String, dynamic> json) {
    return AuthBundle(
      user: User.fromRpcJson(json['user']),
      profile: Profile.fromJson(json['profile']),
      messages: (json['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList(growable: false),
    );
  }

  factory AuthBundle.fromJson(Map<String, dynamic> json) {
    return AuthBundle(
      user: User.fromJson(json['user']),
      profile: Profile.fromJson(json['profile']),
      messages: (json['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'profile': profile.toJson(),
      'messages': messages.map((e) => e.toJson()).toList(growable: false),
    };
  }

  AuthBundle copyWith({
    User? user,
    Profile? profile,
    List<Message>? messages,
  }) {
    return AuthBundle(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [user, profile, messages];
}
