part of 'organizer_contest_edit_page_bloc.dart';

@immutable
final class OrganizerContestEditPageState extends Equatable {
  final BlocStatus status;
  final OrganizerContestEditPageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final OrganizerContestDetailsBundle? contestDetailsBundle;
  final List<XFile>? images;

  const OrganizerContestEditPageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.contestDetailsBundle,
    this.images,
  });

  factory OrganizerContestEditPageState.fromJson(Map<String, dynamic> json) {
    return OrganizerContestEditPageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['is_initialized'] as bool,
      contestDetailsBundle: (json['contest_details_bundle'] != null)
          ? OrganizerContestDetailsBundle.fromJson(json['contest_details_bundle'])
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

  OrganizerContestEditPageState copyWith({
    required BlocStatus status,
    OrganizerContestEditPageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    OrganizerContestDetailsBundle? contestDetailsBundle,
    List<XFile>? images,
  }) {
    return OrganizerContestEditPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      contestDetailsBundle: contestDetailsBundle ?? this.contestDetailsBundle,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        contestDetailsBundle,
        images,
      ];
}
