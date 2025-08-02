part of 'participant_contest_details_page_bloc.dart';

@immutable
final class ParticipantContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final ParticipantContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final ParticipationBundle? ownParticipationBundle;
  // final Work? submittedWork;

  const ParticipantContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.ownParticipationBundle,
  });

  factory ParticipantContestDetailsPageState.fromJson(Map<String, dynamic> json) {
    return ParticipantContestDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      contestDetailsBundle: (json['contest_details_bundle'] != null)
          ? ContestDetailsBundle.fromJson(json['contest_details_bundle'])
          : null,
      ownParticipationBundle: (json['own_participation_bundle'] != null)
          ? ParticipationBundle.fromJson(json['own_participation_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'contest_details_bundle': contestDetailsBundle?.toJson(),
      'own_participation_bundle': ownParticipationBundle?.toJson(),
    };
  }


  ParticipantContestDetailsPageState copyWith({
    required BlocStatus status,
    ParticipantContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    ParticipationBundle? ownParticipationBundle,
  }) {
    return ParticipantContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      ownParticipationBundle: ownParticipationBundle ?? this.ownParticipationBundle,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        contestDetailsBundle,
        ownParticipationBundle,
      ];
}
