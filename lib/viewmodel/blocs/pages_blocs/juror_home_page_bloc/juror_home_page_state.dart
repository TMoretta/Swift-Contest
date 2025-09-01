part of 'juror_home_page_bloc.dart';

@immutable
final class JurorHomePageState extends Equatable {
  final BlocStatus status;
  final JurorHomePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final List<HomeContestBundle>? joinedContestsBundles;
  final List<HomeContestBundle>? filteredContestsBundles;
  final VotingSession? votingSession;

  const JurorHomePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.joinedContestsBundles,
    this.filteredContestsBundles,
    this.votingSession,
  });

  factory JurorHomePageState.fromJson(Map<String, dynamic> json) {
    return JurorHomePageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      joinedContestsBundles: (json['joined_contests_bundles'] as List?)
          ?.map((e) => HomeContestBundle.fromJson(e as Map<String, dynamic>))
          .toList(),
      filteredContestsBundles: (json['filtered_contests_bundles'] as List?)
          ?.map((e) => HomeContestBundle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'is_initialized': isInitialized,
      'joined_contests_bundles': joinedContestsBundles?.map((e) => e.toJson()).toList(),
      'filtered_contests_bundles': filteredContestsBundles?.map((e) => e.toJson()).toList(),
    };
  }


  JurorHomePageState copyWith({
    required BlocStatus status,
    JurorHomePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    List<HomeContestBundle>? joinedContestsBundles,
    List<HomeContestBundle>? filteredContestsBundles,
    VotingSession? votingSession,
  }) {
    return JurorHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      joinedContestsBundles: joinedContestsBundles ?? this.joinedContestsBundles,
      filteredContestsBundles: filteredContestsBundles ?? this.filteredContestsBundles,
      votingSession: votingSession ?? this.votingSession,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        joinedContestsBundles,
        filteredContestsBundles,
        votingSession,
      ];
}
