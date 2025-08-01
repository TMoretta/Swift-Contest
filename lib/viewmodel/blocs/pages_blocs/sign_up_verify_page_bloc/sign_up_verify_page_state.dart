part of 'sign_up_verify_page_bloc.dart';

@immutable
final class SignUpVerifyPageState extends Equatable {
  final BlocStatus status;
  final SignUpVerifyPageEvent? sourceEvent;
  final String? message;

  const SignUpVerifyPageState({
    required this.status,
    this.sourceEvent,
    this.message,
  });

  factory SignUpVerifyPageState.fromJson(Map<String, dynamic> json) {
    return SignUpVerifyPageState(
      status: BlocStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }

  SignUpVerifyPageState copyWith({
    required BlocStatus status,
    SignUpVerifyPageEvent? sourceEvent,
    String? message,
  }) {
    return SignUpVerifyPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
      ];
}
