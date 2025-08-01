part of 'organizer_home_page_bloc.dart';

@immutable
final class OrganizerHomePageState extends Equatable {
  final BlocStatus status;
  final OrganizerHomePageEvent? sourceEvent;
  final bool isInitialized;
  final String? message;
  final List<HomeContestBundle>? createdContestsBundles;
  final List<HomeContestBundle>? filteredContestsBundles;

  const OrganizerHomePageState({
    required this.status,
    this.sourceEvent,
    this.isInitialized = false,
    this.message,
    this.createdContestsBundles,
    this.filteredContestsBundles,
  });

  factory OrganizerHomePageState.fromJson(Map<String, dynamic> json) {
    return OrganizerHomePageState(
      status: BlocStatus.values.byName(json['status']),
      isInitialized: json['isInitialized'] as bool,
      createdContestsBundles: (json['createdContestsBundles'] as List<dynamic>?)
          ?.map((e) => HomeContestBundle.fromJson(e as Map<String, dynamic>))
          .toList(),
      filteredContestsBundles: (json['filteredContestsBundles'] as List<dynamic>?)
          ?.map((e) => HomeContestBundle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'isInitialized': isInitialized,
      'createdContestsBundles': createdContestsBundles?.map((e) => e.toJson()).toList(),
      'filteredContestsBundles': filteredContestsBundles?.map((e) => e.toJson()).toList(),
    };
  }

  OrganizerHomePageState copyWith({
    required BlocStatus status,
    OrganizerHomePageEvent? sourceEvent,
    bool? isInitialized,
    String? message,
    List<HomeContestBundle>? createdContestsBundles,
    List<Message>? messages,
    List<HomeContestBundle>? filteredContestsBundles,
  }) {
    return OrganizerHomePageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      isInitialized: isInitialized ?? this.isInitialized,
      message: message,
      createdContestsBundles: createdContestsBundles ?? this.createdContestsBundles,
      filteredContestsBundles: filteredContestsBundles ?? this.filteredContestsBundles,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        isInitialized,
        message,
        createdContestsBundles,
        filteredContestsBundles,
      ];
}
