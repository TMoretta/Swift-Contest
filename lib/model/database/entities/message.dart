import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String? id;
  final DateTime? createdAt;
  final String? accountId;
  final String title;
  final String body;
  final bool isRead;

  const Message({
    required this.id,
    required this.createdAt,
    required this.accountId,
    required this.title,
    required this.body,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      accountId: json['account_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      isRead: json['is_read'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null)
        'created_at': createdAt!.toUtc().toIso8601String(),
      if(accountId!=null) 'account_id': accountId,
      'title': title,
      'body': body,
      'is_read': isRead,
    };
  }

  Message copyWith({
    String? id,
    DateTime? createdAt,
    String? accountId,
    String? title,
    String? body,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        accountId,
        title,
        body,
        isRead,
      ];
}
