import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/data_models/message.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';

class UserAuthBundle extends Equatable {
  final User user;
  final Profile profile;
  final List<Message> messages;

  const UserAuthBundle({
    required this.user,
    required this.profile,
    required this.messages,
  });

  factory UserAuthBundle.fromRpcJson(Map<String, dynamic> json) {
    return UserAuthBundle(
      user: User.fromJson(json['m_user']),
      profile: Profile.fromJson(json['profile']),
      messages: (json['messages'] as List<dynamic>).map((e) => Message.fromJson(e)).toList(growable: false),
    );
  }

  factory UserAuthBundle.fromJson(Map<String, dynamic> json) {
    return UserAuthBundle(
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

  UserAuthBundle copyWith({
    User? user,
    Profile? profile,
    List<Message>? messages,
  }) {
    return UserAuthBundle(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [user, profile, messages];
}
