part of 'organizer_jury_details_page_bloc.dart';

@immutable
final class OrganizerJuryDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerJuryDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final JuryBundle? juryBundle;

  const OrganizerJuryDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.juryBundle,
  });

  OrganizerJuryDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerJuryDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    JuryBundle? juryBundle,
  }) {
    return OrganizerJuryDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      juryBundle: juryBundle ?? this.juryBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        juryBundle,
      ];
}
