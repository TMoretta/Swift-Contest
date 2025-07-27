import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/db/entities/account.dart';
import 'package:swift_contest/model/db/entities/message.dart';
import 'package:swift_contest/model/db/entities/profile.dart';

class AuthBundle extends Equatable {
  final Account account;
  final Profile profile;
  final List<Message> messages;

  const AuthBundle({
    required this.account,
    required this.profile,
    required this.messages,
  });

  factory AuthBundle.fromJson(Map<String, dynamic> json) {
    return AuthBundle(
      account: Account.fromJson(json['account']),
      profile: Profile.fromJson(json['profile']),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => Message.fromJson(e))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
      'profile': profile.toJson(),
      'messages': messages.map((e) => e.toJson()).toList(growable: false),
    };
  }

  AuthBundle copyWith({
    Account? account,
    Profile? profile,
    List<Message>? messages,
  }) {
    return AuthBundle(
      account: account ?? this.account,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [account, profile, messages];
}
