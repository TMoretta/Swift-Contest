import 'package:equatable/equatable.dart';

class User extends Equatable{
  final String id;
  final String email;

  const User({
    required this.id,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
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
