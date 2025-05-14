// import 'package:equatable/equatable.dart';
//
// class VotingSessionToken extends Equatable {
//   final String id;
//   final DateTime createdAt;
//   final String votingSessionId;
//   final String token;
//
//   const VotingSessionToken({
//     required this.id,
//     required this.createdAt,
//     required this.votingSessionId,
//     required this.token,
//   });
//
//   factory VotingSessionToken.fromJson(Map<String,dynamic> json) {
//     return VotingSessionToken(
//       id: json['id'] as String,
//       createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
//       votingSessionId: json['voting_session_id'] as String,
//       token: json['token'] as String,
//     );
//   }
//
//   Map<String,dynamic> toJson() {
//     return {
//       'id': id,
//       'created_at': createdAt.toUtc().toIso8601String(),
//       'voting_session_id': votingSessionId,
//       'token': token,
//     };
//   }
//
//   @override
//   List<Object?> get props => [id, createdAt, votingSessionId, token];
// }
