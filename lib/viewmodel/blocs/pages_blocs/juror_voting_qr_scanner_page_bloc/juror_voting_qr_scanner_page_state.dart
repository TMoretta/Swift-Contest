part of 'juror_voting_qr_scanner_page_bloc.dart';

@immutable
final class JurorVotingQrScannerPageState extends Equatable {
  final BlocStatus status;
  final JurorVotingQrScannerPageEvent? sourceEvent;
  final String? message;
  final VotingSession? votingSession;
  final PermissionStatus? cameraPermissionStatus;

  const JurorVotingQrScannerPageState({
    required this.status,
    this.sourceEvent,
    this.message,
    this.votingSession,
    this.cameraPermissionStatus,
  });

  factory JurorVotingQrScannerPageState.fromJson(Map<String, dynamic> json) {
    return JurorVotingQrScannerPageState(
      status: BlocStatus.values.byName(json['status']),
      votingSession: VotingSession.fromJson(json['votingSession']),
      cameraPermissionStatus: PermissionStatus.values.byName(json['cameraPermissionStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'votingSession': votingSession?.toJson(),
      'cameraPermissionStatus': cameraPermissionStatus?.name,
    };
  }

  JurorVotingQrScannerPageState copyWith({
    required BlocStatus status,
    JurorVotingQrScannerPageEvent? sourceEvent,
    String? message,
    VotingSession? votingSession,
    PermissionStatus? cameraPermissionStatus,
  }) {
    return JurorVotingQrScannerPageState(
      status: status,
      sourceEvent: sourceEvent ?? this.sourceEvent,
      message: message,
      votingSession: votingSession ?? this.votingSession,
      cameraPermissionStatus: cameraPermissionStatus ?? this.cameraPermissionStatus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        sourceEvent,
        message,
        votingSession,
        cameraPermissionStatus,
      ];
}
