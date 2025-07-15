import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final bool isAdmin;

  const User({
    required this.id,
    required this.email,
    required this.isAdmin,
  });

  factory User.fromRpcJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      isAdmin: (json['user_metadata'] as Map<String,dynamic>?)?['is_admin'] ?? false,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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

  User copyWith({
    String? id,
    String? email,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  @override
  List<Object?> get props => [id, email, isAdmin];
}

class UserModel extends Equatable {
  final String? id;
  final String? email;
  final bool? isAdmin;

  const UserModel({
    this.id,
    this.email,
    this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      email: json['email'] as String?,
      isAdmin: json['is_super_admin'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_super_admin': isAdmin,
    };
  }

  @override
  List<Object?> get props => [id, email, isAdmin];
}
