part of 'juror_contest_details_page_bloc.dart';

@immutable
final class JurorContestDetailsPageState extends Equatable {
  final BlocStatus status;
  final JurorContestDetailsPageEvent? sourceEvent;
  final String? message;
  final ContestDetailsBundle? contestDetailsBundle;

  const JurorContestDetailsPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.contestDetailsBundle,
  });

  JurorContestDetailsPageState copyWith({
    required BlocStatus status,
    JurorContestDetailsPageEvent? sourceEvent,
    String? message,
    ContestDetailsBundle? contestDetailsBundle,
  }) {
    return JurorContestDetailsPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
    );
  }

  @override
  List<Object?> get props => [status, sourceEvent, message, contestDetailsBundle];
}
