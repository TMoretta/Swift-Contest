import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/entities/profile.dart';

class AccountBundle extends Equatable {
  final Account account;
  final Profile profile;
  final List<Message> messages;

  const AccountBundle({
    required this.account,
    required this.profile,
    required this.messages,
  });

  factory AccountBundle.fromJson(Map<String, dynamic> json) {
    return AccountBundle(
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

  AccountBundle copyWith({
    Account? account,
    Profile? profile,
    List<Message>? messages,
  }) {
    return AccountBundle(
      account: account ?? this.account,
      profile: profile ?? this.profile,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [account, profile, messages];
}
