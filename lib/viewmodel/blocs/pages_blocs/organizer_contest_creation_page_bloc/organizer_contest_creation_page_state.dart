part of 'organizer_contest_creation_page_bloc.dart';

@immutable
final class OrganizerContestCreationPageState extends Equatable {
  final BlocStatus status;
  final OrganizerContestCreationPageEvent? sourceEvent;
  final String? message;

  const OrganizerContestCreationPageState({
    required this.status,
    this.sourceEvent,
    this.message,
  });

  OrganizerContestCreationPageState copyWith({
    required BlocStatus status,
    OrganizerContestCreationPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
  }) {
    return OrganizerContestCreationPageState(
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
