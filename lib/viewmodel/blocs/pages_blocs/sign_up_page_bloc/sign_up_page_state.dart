part of 'sign_up_page_bloc.dart';

@immutable
final class SignUpPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final User? user;

  const SignUpPageState({
    required this.status,
    this.message,
    this.user,
  });

  SignUpPageState copyWith({
    required BlocStatus status,
    String? message,
    User? user,
  }) {
    return SignUpPageState(
      status: status,
      message: message,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [status,message,user];
}