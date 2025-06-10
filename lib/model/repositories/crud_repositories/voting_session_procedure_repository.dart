// import 'dart:async';
// import 'package:dartz/dartz.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:swift_contest/model/data_models/voting_session_procedure.dart';
// import 'package:swift_contest/utils/failures/failures.dart';
//
// abstract interface class VotingSessionProcedureRepository {
//   Future<Either<Failure, VotingSessionProcedure>> createVotingSessionProcedure({
//     required VotingSessionProcedure votingSessionProcedure,
//   });
//
//   Future<Either<Failure, VotingSessionProcedure>> updateVotingSessionProcedure({
//     required VotingSessionProcedure votingSessionProcedure,
//   });
//
//   Future<Either<Failure, VotingSessionProcedure>> deleteVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure, VotingSessionProcedure?>> getVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure, VotingSessionProcedure?>>
//       getVotingSessionProcedureByVotingSessionId({
//     required String votingSessionId,
//   });
//
//   Future<Either<Failure, Unit>> beginVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure, Unit>> startVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure, Unit>> cancelVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure, Unit>> endVotingSessionProcedureById({
//     required String id,
//   });
//
//   Future<Either<Failure,Stream<Either<Failure, VotingSessionProcedure?>>>> getVotingSessionProcedureStream({
//     required String votingSessionProcedureId,
//   });
// }
//
// class VotingSessionProcedureRepositoryImpl implements VotingSessionProcedureRepository {
//   final SupabaseClient _supabase;
//
//   VotingSessionProcedureRepositoryImpl({required SupabaseClient supabaseClient})
//       : _supabase = supabaseClient;
//
//   @override
//   Future<Either<Failure, VotingSessionProcedure>> createVotingSessionProcedure({
//     required VotingSessionProcedure votingSessionProcedure,
//   }) async {
//     try {
//       final Map<String, dynamic> res = await _supabase.rpc('create_voting_session_procedure',params: {'p_voting_session_procedure': votingSessionProcedure.toJson()});
//       return right(VotingSessionProcedure.fromJson(res));
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, VotingSessionProcedure>> updateVotingSessionProcedure({
//     required VotingSessionProcedure votingSessionProcedure,
//   }) async {
//     try {
//       final Map<String, dynamic> res = await _supabase.rpc('update_voting_session_procedure',params: {'p_voting_session_procedure': votingSessionProcedure.toJson()});
//       return right(VotingSessionProcedure.fromJson(res));
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, VotingSessionProcedure>> deleteVotingSessionProcedureById(
//       {required String id,}) async {
//     try {
//       final Map<String, dynamic> res = await _supabase.rpc('delete_voting_session_procedure_by_id',params: {'p_id': id});
//       return right(VotingSessionProcedure.fromJson(res));
//     }on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, VotingSessionProcedure?>> getVotingSessionProcedureById({
//     required String id,
//   }) async {
//     try {
//       final List<Map<String, dynamic>> res =
//           await _supabase.rpc('get_voting_session_procedure_by_id',params: {'p_id': id});
//       if (res.isEmpty) {
//         return right(null);
//       }
//       return right(VotingSessionProcedure.fromJson(res.first));
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, VotingSessionProcedure?>>
//       getVotingSessionProcedureByVotingSessionId({
//     required String votingSessionId,
//   }) async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase.rpc('get_voting_session_procedure_by_voting_session_id',params: {'p_voting_session_id': votingSessionId});
//       if (res.isEmpty) {
//         return right(null);
//       }
//       return right(VotingSessionProcedure.fromJson(res.first));
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> beginVotingSessionProcedureById(
//       {required String id}) async {
//     try {
//       await _supabase.rpc('begin_voting_session_procedure_by_id', params: {'p_id': id});
//       return right(unit);
//     }on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> startVotingSessionProcedureById({
//     required String id,
//   }) async {
//     try {
//       await _supabase.rpc('start_voting_session_procedure_by_id', params: {'p_id': id});
//       return right(unit);
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> cancelVotingSessionProcedureById({
//     required String id,
//   }) async {
//     try {
//       await _supabase.rpc('cancel_voting_session_procedure_by_id', params: {'p_id': id});
//       return right(unit);
//     }on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> endVotingSessionProcedureById({
//     required String id,
//   }) async {
//     try {
//       await _supabase.rpc('end_voting_session_procedure_by_id', params: {'p_id': id});
//       return right(unit);
//     } on PostgrestException catch (e) {
//       return left(Failure(message: e.message));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure,Stream<Either<Failure, VotingSessionProcedure?>>>> getVotingSessionProcedureStream({
//     required String votingSessionProcedureId,
//   }) async {
//     try {
//       return right(_supabase
//           .from('voting_session_procedures')
//           .stream(primaryKey: ['id'])
//           .eq('id', votingSessionProcedureId)
//           .timeout(const Duration(hours: 24))
//           .map((rows) {
//         if (rows.isEmpty) {
//           return right(null);
//         }
//         return right(VotingSessionProcedure.fromJson(rows.first));
//       }));
//     } catch (e) {
//       return left(Failure());
//     }
//   }
// }
