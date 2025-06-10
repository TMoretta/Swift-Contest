part of 'sign_in_page_bloc.dart';

@immutable
final class SignInPageState extends Equatable {
  final BlocStatus status;
  final SignInPageEvent? sourceEvent;
  final String? message;

  const SignInPageState({required this.status, this.sourceEvent, this.message,});

  SignInPageState copyWith({
    required BlocStatus status,
    SignInPageEvent? sourceEvent,
    String? message,
  }) {
    return SignInPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message];
}
