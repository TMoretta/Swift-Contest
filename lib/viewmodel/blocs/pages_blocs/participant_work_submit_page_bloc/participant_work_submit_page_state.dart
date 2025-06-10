part of 'participant_work_submit_page_bloc.dart';

@immutable
final class ParticipantWorkSubmitPageState extends Equatable {
  final BlocStatus status;
  final ParticipantWorkSubmitPageEvent? sourceEvent;
  final String? message;
  final Work? work;

  const ParticipantWorkSubmitPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.work,
  });

  ParticipantWorkSubmitPageState copyWith({
    required BlocStatus status,
    ParticipantWorkSubmitPageEvent? sourceEvent,
    String? message,
    Work? work,
  }) {
    return ParticipantWorkSubmitPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      work: work ?? this.work,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, work];
}
