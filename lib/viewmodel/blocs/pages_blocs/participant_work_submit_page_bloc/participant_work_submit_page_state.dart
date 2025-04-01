part of 'participant_work_submit_page_bloc.dart';

@immutable
final class ParticipantWorkSubmitPageState extends Equatable {
  final BlocStatus status;
  final String? message;
  final Work? work;

  const ParticipantWorkSubmitPageState({
    required this.status,
    this.message,
    this.work,
  });

  ParticipantWorkSubmitPageState copyWith({
    required BlocStatus status,
    String? message,
    Work? work,
  }) {
    return ParticipantWorkSubmitPageState(
      status: status,
      message: message,
      work: work ?? this.work,
    );
  }

  @override
  List<Object?> get props => [status, message, work];
}
