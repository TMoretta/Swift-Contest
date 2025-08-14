part of 'participant_work_submit_page_bloc.dart';

@immutable
sealed class ParticipantWorkSubmitPageEvent extends Equatable {}

final class ParticipantWorkSubmitPageSubmitWork extends ParticipantWorkSubmitPageEvent {
  final String contestId;
  final String name;
  final String description;
  final List<XFile> images;

  ParticipantWorkSubmitPageSubmitWork({
    required this.contestId,
    required this.name,
    required this.description,
    required this.images,
  });

  @override
  List<Object?> get props => [
        contestId,
        name,
        description,
        images,
      ];
}
