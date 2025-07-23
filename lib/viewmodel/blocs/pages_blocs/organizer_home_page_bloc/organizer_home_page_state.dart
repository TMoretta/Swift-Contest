part of 'organizer_home_page_bloc.dart';

@immutable
final class OrganizerHomePageState extends Equatable {
  final BlocStatus status;
  final OrganizerHomePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final List<HomeContestBundle>? createdContestsBundles;
  final List<HomeContestBundle>? filteredContestsBundles;

  const OrganizerHomePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.createdContestsBundles,
    this.filteredContestsBundles,
  });

  OrganizerHomePageState copyWith({
    required BlocStatus status,
    OrganizerHomePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    List<HomeContestBundle>? createdContestsBundles,
    List<Message>? messages,
    List<HomeContestBundle>? filteredContestsBundles,
  }) {
    return OrganizerHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      createdContestsBundles: createdContestsBundles ?? this.createdContestsBundles,
      filteredContestsBundles: filteredContestsBundles ?? this.filteredContestsBundles,

    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        createdContestsBundles,
        filteredContestsBundles,
      ];
}
