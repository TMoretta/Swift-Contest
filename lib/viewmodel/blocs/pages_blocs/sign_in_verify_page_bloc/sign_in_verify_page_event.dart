part of 'sign_in_verify_page_bloc.dart';

sealed class SignInVerifyPageEvent extends Equatable {
  const SignInVerifyPageEvent();
}

final class SignInVerifyOtp extends SignInVerifyPageEvent {
  final String email;
  final String otp;

  const SignInVerifyOtp({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}
