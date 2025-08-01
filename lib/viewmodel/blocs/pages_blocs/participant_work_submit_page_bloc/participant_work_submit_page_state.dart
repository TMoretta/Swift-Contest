part of 'participant_work_submit_page_bloc.dart';

@immutable
final class ParticipantWorkSubmitPageState extends Equatable {
  final BlocStatus status;
  final ParticipantWorkSubmitPageEvent? sourceEvent;
  final String? message;

  const ParticipantWorkSubmitPageState({
    required this.status,
    this.sourceEvent,
    this.message,
  });

  factory ParticipantWorkSubmitPageState.fromJson(Map<String, dynamic> json) {
    return ParticipantWorkSubmitPageState(
      status: BlocStatus.values.byName(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
    };
  }

  ParticipantWorkSubmitPageState copyWith({
    required BlocStatus status,
    ParticipantWorkSubmitPageEvent? sourceEvent,
    String? message,
  }) {
    return ParticipantWorkSubmitPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message];
}
