import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final DateTime createdAt;
  final String profileId;
  final String title;
  final String body;
  final bool isRead;

  const Message({
    required this.id,
    required this.createdAt,
    required this.profileId,
    required this.title,
    required this.body,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      profileId: json['profile_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool,
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
    };
  }

  Message copyWith({
    String? id,
    DateTime? createdAt,
    String? profileId,
    String? title,
    String? body,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      profileId: profileId ?? this.profileId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
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
      ];
}

class MessageModel extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? profileId;
  final String? title;
  final String? body;
  final bool? isRead;

  const MessageModel({
    this.id,
    this.createdAt,
    this.profileId,
    this.title,
    this.body,
    this.isRead,
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
      ];
}
