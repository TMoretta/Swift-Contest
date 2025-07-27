import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String email;
  final bool isAdmin;

  const Account({
    required this.id,
    required this.email,
    required this.isAdmin,
  });

  factory Account.fromDbJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      email: json['email'] as String,
      isAdmin: (json['user_metadata'] as Map<String,dynamic>?)?['is_admin'] ?? false,
    );
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      email: json['email'] as String,
      isAdmin: (json['is_admin'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_admin': isAdmin,
    };
  }

  Account copyWith({
    String? id,
    String? email,
    bool? isAdmin,
  }) {
    return Account(
      id: id ?? this.id,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [id, email, isAdmin];
}
