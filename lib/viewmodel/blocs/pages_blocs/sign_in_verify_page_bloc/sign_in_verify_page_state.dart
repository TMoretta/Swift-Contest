part of 'sign_in_verify_page_bloc.dart';

@immutable
final class SignInVerifyPageState extends Equatable {
  final BlocStatus status;
  final SignInVerifyPageEvent? sourceEvent;
  final String? message;

  const SignInVerifyPageState({required this.status, this.sourceEvent, this.message,});

  SignInVerifyPageState copyWith({
    required BlocStatus status,
    SignInVerifyPageEvent? sourceEvent,
    String? message,
  }) {
    return SignInVerifyPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message];
}