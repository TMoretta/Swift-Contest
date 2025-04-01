part of 'sign_in_page_bloc.dart';

@immutable
final class SignInPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final User? user;

  const SignInPageState({
    required this.status,
    this.message,
    this.user,
  });

  SignInPageState copyWith({
    required BlocStatus status,
    String? message,
    User? user,
  }) {
    return SignInPageState(
      status: status,
      message: message,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status,message,user];
}
