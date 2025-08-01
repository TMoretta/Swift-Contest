part of 'sign_up_page_bloc.dart';

@immutable
final class SignUpPageState extends Equatable {
  final BlocStatus status;
  final SignUpPageEvent? sourceEvent;
  final String? message;

  const SignUpPageState({required this.status, this.sourceEvent, this.message,});

  factory SignUpPageState.fromJson(Map<String, dynamic> json) {
    return SignUpPageState(
      status: BlocStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }


  SignUpPageState copyWith({
    required BlocStatus status,
    SignUpPageEvent? sourceEvent,
    String? message,
  }) {
    return SignUpPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message,];
}