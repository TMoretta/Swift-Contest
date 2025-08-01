part of 'organizer_work_details_page_bloc.dart';

@immutable
final class OrganizerWorkDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerWorkDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ParticipationBundle? participationBundle;

  const OrganizerWorkDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.participationBundle,
  });

  factory OrganizerWorkDetailsPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerWorkDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      participationBundle: (json['participation_bundle'] != null)
          ? ParticipationBundle.fromJson(json['participation_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'participation_bundle': participationBundle?.toJson(),
    };
  }

  OrganizerWorkDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerWorkDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ParticipationBundle? participationBundle,
  }) {
    return OrganizerWorkDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      participationBundle: participationBundle ?? this.participationBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        participationBundle,
      ];
}
