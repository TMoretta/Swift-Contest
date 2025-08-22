part of 'inbox_bloc.dart';

@immutable
final class InboxState extends Equatable {
  final BlocStatus status;
  final InboxEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final List<Message>? messages;

  const InboxState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.messages,
  });

  InboxState copyWith({
    required BlocStatus status,
    InboxEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    List<Message>? messages,
  }) {
    return InboxState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        messages,
      ];
}
