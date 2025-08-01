part of 'organizer_contest_details_page_bloc.dart';

@immutable
final class OrganizerContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final OrganizerContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;

  const OrganizerContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
  });


factory OrganizerContestDetailsPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerContestDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['isInitialized'] as bool,
      contestDetailsBundle: json['contestDetailsBundle'] != null
          ? ContestDetailsBundle.fromJson(json['contestDetailsBundle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'isInitialized': isInitialized,
      'contestDetailsBundle': contestDetailsBundle?.toJson(),
    };
  }

  OrganizerContestDetailsPageState copyWith({
    required BlocStatus status,
    OrganizerContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
  }) {
    return OrganizerContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, isInitialized, message, contestDetailsBundle];
}