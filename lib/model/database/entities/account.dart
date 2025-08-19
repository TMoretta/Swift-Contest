import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String email;
  final bool isAnonymous;

  const Account({
    required this.id,
    required this.email,
    required this.isAnonymous,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_anonymous': isAnonymous,
    };
  }

  Account copyWith({
    String? id,
    String? email,
    bool? isAnonymous,
  }) {
    return Account(
      id: id ?? this.id,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        isAnonymous,
      ];
}
