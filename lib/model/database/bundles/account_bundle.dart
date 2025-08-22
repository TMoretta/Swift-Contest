import 'package:equatable/equatable.dart';
import 'package:swift_contest/model/database/entities/account.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/entities/profile.dart';

class AccountBundle extends Equatable {
  final Account account;
  final Profile profile;

  const AccountBundle({
    required this.account,
    required this.profile,
  });

  factory AccountBundle.fromJson(Map<String, dynamic> json) {
    return AccountBundle(
      account: Account.fromJson(json['account']),
      profile: Profile.fromJson(json['profile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
      'profile': profile.toJson(),
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
    );
  }

  @override
  List<Object?> get props => [account, profile];
}
