part of 'simple_juror_home_page_bloc.dart';

@immutable
final class SimpleJurorHomePageState extends Equatable {
  final BlocStatus status;
  final SimpleJurorHomePageEvent? sourceEvent;
  final String? message;

  const SimpleJurorHomePageState({
    required this.status,
    this.sourceEvent,
    this.message,
  });

  factory SimpleJurorHomePageState.fromJson(Map<String, dynamic> json) {
    return SimpleJurorHomePageState(
      status: BlocStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }

  SimpleJurorHomePageState copyWith({
    required BlocStatus status,
    SimpleJurorHomePageEvent? sourceEvent,
    String? message,
  }) {
    return SimpleJurorHomePageState(
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
