part of 'organizer_work_details_page_bloc.dart';

@immutable
final class OrganizerWorkDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerWorkDetailsPageEvent? sourceEvent;
  final String? message;
  final ParticipationBundle? participationBundle;

  const OrganizerWorkDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.participationBundle,
  });

  OrganizerWorkDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerWorkDetailsPageEvent? sourceEvent,
    String? message,
    ParticipationBundle? participationBundle,
  }) {
    return OrganizerWorkDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      participationBundle: participationBundle ?? this.participationBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        participationBundle,
      ];
}
