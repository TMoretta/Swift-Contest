import 'package:equatable/equatable.dart';

class User extends Equatable{
  final String id;
  final String email;

  const User({
    required this.id,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  Map<String, dynamic> toRpcJson() {
    return {
      'p_id': id,
      'p_email': email,
    };
  }

  User copyWith({
    String? id,
    String? email,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [id,email];
}

class UserNullable extends Equatable{
  final String? id;
  final String? email;

  const UserNullable({
    this.id,
    this.email,
  });

  factory UserNullable.fromJson(Map<String, dynamic> json) {
    return UserNullable(
      id: json['id'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id,email];
}
