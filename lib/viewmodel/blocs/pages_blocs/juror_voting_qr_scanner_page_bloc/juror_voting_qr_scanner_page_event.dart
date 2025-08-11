part of 'juror_voting_qr_scanner_page_bloc.dart';

sealed class JurorVotingQrScannerPageEvent extends Equatable {
  const JurorVotingQrScannerPageEvent();
}

final class JurorVotingQrScannerPageAccessVotingAsSimpleJuror extends JurorVotingQrScannerPageEvent {
  final String token;

  const JurorVotingQrScannerPageAccessVotingAsSimpleJuror({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
