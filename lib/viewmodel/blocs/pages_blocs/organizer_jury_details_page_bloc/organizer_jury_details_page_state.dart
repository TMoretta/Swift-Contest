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

  factory OrganizerJuryDetailsPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerJuryDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      juryBundle: (json['jury_bundle'] != null)
          ? JuryBundle.fromJson(json['jury_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'jury_bundle': juryBundle?.toJson(),
    };
  }

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
