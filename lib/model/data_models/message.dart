import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final DateTime createdAt;
  final String profileId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? deletedAt;

  const Message({
    required this.id,
    required this.createdAt,
    required this.profileId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.deletedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool,
      deletedAt: (json['deleted_at'] != null)
          ? DateTime.parse(json['deleted_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toUtc().toIso8601String(),
      'profile_id': profileId,
      'title': title,
      'body': body,
      'is_read': isRead,
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  Message copyWith({
    String? id,
    DateTime? createdAt,
    String? profileId,
    String? title,
    String? body,
    bool? isRead,
    DateTime? deletedAt,
  }) {
    return Message(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        profileId,
        title,
        body,
        isRead,
        deletedAt,
      ];
}

class MessageModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? profileId;
  final String? title;
  final String? body;
  final bool? isRead;
  final DateTime? deletedAt;

  const MessageModel({
    this.id,
    this.createdAt,
    this.profileId,
    this.title,
    this.body,
    this.isRead,
    this.deletedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      profileId: json['profile_id'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      isRead: json['is_read'] as bool?,
      deletedAt: (json['deleted_at'] != null)
          ? DateTime.parse(json['deleted_at']).toLocal() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt?.toUtc().toIso8601String(),
      'profile_id': profileId,
      'title': title,
      'body': body,
      'is_read': isRead,
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        profileId,
        title,
        body,
        isRead,
        deletedAt,
      ];
}
