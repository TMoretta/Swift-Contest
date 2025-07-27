// import 'dart:io';
//
// import 'package:fpdart/fpdart.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:swift_contest/model/db/bundles/contest_details_bundle.dart';
// import 'package:swift_contest/model/db/bundles/home_contest_bundle.dart';
// import 'package:swift_contest/model/db/bundles/simple_juror_and_voting_session_bundle.dart';
// import 'package:swift_contest/model/db/bundles/voting_session_procedure_bundle.dart';
// import 'package:swift_contest/model/db/entities/voting_form_field.dart';
// import 'package:swift_contest/model/db/entities/voting_session.dart';
// import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
// import 'package:swift_contest/utils/failures/failures.dart';
//
// abstract interface class JurorRepository {
//   Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests();
//
//   Future<Either<Failure,ContestDetailsBundle>> getContestDetails({required String contestId});
//
//   Future<Either<Failure, Unit>> joinContest({
//     required String token,
//   });
//
//   Future<Either<Failure,Unit>> leaveContest({required String contestId});
//
//   Future<Either<Failure, Unit>> jurorSubmitVotes({
//     required String votingSessionId,
//     required String contestId,
//     required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
//   });
//
//   Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
//     required String votingSessionId,
//   });
//
//   Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
//     required String fullName,
//     required String token,
//   });
//
//   Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
//     required String simpleJurorId,
//     required String votingSessionId,
//     required String contestId,
//     required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
//   });
//
//   Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
//     required String votingSessionId,
//   });
// }
//
// class JurorRepositoryImpl implements JurorRepository {
//   final SupabaseClient _supabase;
//
//   JurorRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;
//
//   @override
//   Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests() async {
//     try {
//       final List<Map<String, dynamic>> res =
//           await _supabase.rpc('juror_get_joined_contests');
//       return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure,ContestDetailsBundle>> getContestDetails({required String contestId}) async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase
//           .rpc('juror_get_contest_details',params: {'p_contest_id':contestId});
//       return right(ContestDetailsBundle.fromRpcJson(res.first));
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> joinContest({
//     required String token,
//   }) async {
//     try {
//       await _supabase.rpc('juror_join_contest', params: {
//         'p_token': token,
//       });
//       return right(unit);
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure,Unit>> leaveContest({required String contestId}) async {
//     try {
//       await _supabase.rpc('juror_leave_contest', params: {
//         'p_contest_id' : contestId,
//       });
//       return right(unit);
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> jurorSubmitVotes({
//     required String votingSessionId,
//     required String contestId,
//     required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
//   }) async {
//     try {
//       final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
//           votesPerParticipantMap.map(
//               (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
//       await _supabase.rpc('juror_submit_votes', params: {
//         'p_voting_session_id': votingSessionId,
//         'p_contest_id': contestId,
//         'p_votes_per_participant_map': votesPerParticipantMapWithIds,
//       });
//       return right(unit);
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
//     required String votingSessionId,
//   }) async {
//     try {
//       return right(_supabase
//           .from('voting_sessions')
//           .stream(primaryKey: ['id'])
//           .eq('id', votingSessionId)
//           .timeout(const Duration(hours: 24))
//           .map((rows) {
//             if (rows.isEmpty) {
//               return right(null);
//             }
//             return right(VotingSession.fromJson(rows.first));
//           }));
//     } on SocketException {
//       return left(Failure('Network error'));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
//     required String fullName,
//     required String token,
//   }) async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase.rpc(
//           'juror_access_voting_as_simple_juror',
//           params: {'p_full_name': fullName, 'p_token': token});
//       return right(SimpleJurorAndVotingSessionBundle.fromJson(res.first));
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
//     required String simpleJurorId,
//     required String votingSessionId,
//     required String contestId,
//     required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
//   }) async {
//     try {
//       final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
//           votesPerParticipantMap.map(
//               (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
//       await _supabase.rpc('simple_juror_submit_votes', params: {
//         'p_simple_juror_id': simpleJurorId,
//         'p_voting_session_id': votingSessionId,
//         'p_contest_id': contestId,
//         'p_votes_per_participant_map': votesPerParticipantMapWithIds,
//       });
//       return right(unit);
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
//     required String votingSessionId,
//   }) async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase.rpc(
//           'juror_get_voting_session_procedure_bundle',
//           params: {'p_voting_session_id': votingSessionId});
//       if (res.isEmpty) {
//         return left(Failure('Voting session not found'));
//       }
//       return right(VotingSessionProcedureBundle.fromRpcJson(res.first));
//     } on SocketException {
//       return left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return left(Failure(e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
// }
