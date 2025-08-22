part of 'inbox_bloc.dart';

sealed class InboxEvent extends Equatable {
  const InboxEvent();
}

final class InboxGetStream extends InboxEvent {
  @override
  List<Object?> get props => [];
}

final class InboxMarkMessageAsRead extends InboxEvent {
  final String messageId;

  const InboxMarkMessageAsRead({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final class InboxDeleteMessage extends InboxEvent {
  final String messageId;

  const InboxDeleteMessage({required this.messageId});

  @override
  List<Object?> get props => [messageId];
}

final class InboxDeleteAllMessages extends InboxEvent {
  @override
  List<Object?> get props => [];
}

final class InboxClear extends InboxEvent {
  @override
  List<Object?> get props => [];
}

