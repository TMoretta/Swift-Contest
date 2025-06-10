part of 'sign_up_verify_page_bloc.dart';

sealed class SignUpVerifyPageEvent extends Equatable {
  const SignUpVerifyPageEvent();
}

final class SignUpVerifyOtp extends SignUpVerifyPageEvent {
  final String email;
  final String otp;

  const SignUpVerifyOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
