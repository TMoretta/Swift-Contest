part of 'participant_contest_details_page_bloc.dart';

@immutable
final class ParticipantContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final ParticipantContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final Work? submittedWork;

  const ParticipantContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.submittedWork,
  });

  factory ParticipantContestDetailsPageState.fromJson(Map<String, dynamic> json) {
    return ParticipantContestDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      contestDetailsBundle: (json['contest_details_bundle'] != null)
          ? ContestDetailsBundle.fromJson(json['contest_details_bundle'])
          : null,
      submittedWork:
          (json['submitted_work'] != null) ? Work.fromJson(json['submitted_work']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'contest_details_bundle': contestDetailsBundle?.toJson(),
      'submitted_work': submittedWork?.toJson(),
    };
  }


  ParticipantContestDetailsPageState copyWith({
    required BlocStatus status,
    ParticipantContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    Work? submittedWork,
  }) {
    return ParticipantContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      submittedWork: submittedWork ?? this.submittedWork,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        contestDetailsBundle,
        submittedWork,
      ];
}
