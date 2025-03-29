part of 'participant_work_submit_page_bloc.dart';

@immutable
sealed class ParticipantWorkSubmitPageState {}

final class ParticipantWorkSubmitPageInitial extends ParticipantWorkSubmitPageState {}

final class ParticipantWorkSubmitPageLoading extends ParticipantWorkSubmitPageState {}

final class ParticipantWorkSubmitPageSuccess extends ParticipantWorkSubmitPageState {
  final Work work;

  ParticipantWorkSubmitPageSuccess({required this.work});
}

final class ParticipantWorkSubmitPageFailure extends ParticipantWorkSubmitPageState {
  final String message;

  ParticipantWorkSubmitPageFailure({required this.message});
}

