part of 'organizer_home_page_bloc.dart';

@immutable
final class OrganizerHomePageState extends Equatable {
  final BlocStatus status;
  final OrganizerHomePageEvent? sourceEvent;
  final String? message;
  final List<HomeContestBundle>? createdContestsBundles;

  const OrganizerHomePageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.createdContestsBundles,
  });

  OrganizerHomePageState copyWith({
    required BlocStatus status,
    OrganizerHomePageEvent? sourceEvent,
    String? message,
    List<HomeContestBundle>? createdContestsBundles,
    List<Message>? messages,
  }) {
    return OrganizerHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      createdContestsBundles: createdContestsBundles ?? this.createdContestsBundles,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        createdContestsBundles,
      ];
}
