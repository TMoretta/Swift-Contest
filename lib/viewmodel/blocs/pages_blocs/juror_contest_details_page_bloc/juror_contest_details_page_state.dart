part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final JurorContestDetailsPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;
  final String? rankingFileUrl;

  const JurorContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.rankingFileUrl,
  });

  factory JurorContestDetailsPageState.fromJson(Map<String, dynamic> json) {
    return JurorContestDetailsPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      contestDetailsBundle: (json['contest_details_bundle'] != null)
          ? ContestDetailsBundle.fromJson(json['contest_details_bundle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'contest_details_bundle': contestDetailsBundle?.toJson(),
    };
  }

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    JurorContestDetailsPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
    String? rankingFileUrl,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      rankingFileUrl: rankingFileUrl,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        contestDetailsBundle,
        rankingFileUrl,
      ];
}
