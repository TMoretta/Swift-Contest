import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/juror_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/bundles/juror_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/daos/account_dao.dart';
import 'package:swift_contest/model/database/daos/juration_dao.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests();

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, Unit>> joinContest({
    required String token,
  });

  Future<Either<Failure, Unit>> leaveContest({required String contestId});

  Future<Either<Failure, JurorVotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, VotingSessionJuror>> getOwnVotingSessionJuration({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> submitVotes({
    required String votingSessionId,
    required List<Map<String,dynamic>> votesPayload,
    required double? jurorLat,
    required double? jurorLon,
  });

// Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
//   required String fullName,
//   required String token,
// });
//
// Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
//   required String simpleJurorId,
//   required String votingSessionId,
//   required String contestId,
//   required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
// });
}

class JurorRepositoryImpl implements JurorRepository {
  final SupabaseClient _supabase;
  final AccountDao _accountDao;
  final JurationDao _jurationDao;

  JurorRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AccountDao accountDao,
    required JurationDao jurationDao,
  })  : _supabase = supabaseClient,
        _accountDao = accountDao,
        _jurationDao = jurationDao;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests() async {
    return handleDatabaseCall(
      () async {
        final List<Map<String, dynamic>> res = await _supabase.rpc('juror_get_joined_contests');
        return Either.right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
      },
    );
  }

  @override
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    return handleDatabaseCall(
      () async {
        final Map<String, dynamic> res = await _supabase
            .rpc('user_get_contest_details', params: {'p_contest_id': contestId}).single();
        return Either.right(ContestDetailsBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> joinContest({required String token}) async {
    await _supabase.rpc('juror_join_contest', params: {
      'p_token': token,
    });
    return Either.right(unit);
  }

  @override
  Future<Either<Failure, Unit>> leaveContest({required String contestId}) async {
    final eitherAccount = await _accountDao.getCurrent();
    if (eitherAccount.isLeft()) {
      return Either.left(eitherAccount.getLeft().toNullable()!);
    }
    final accountId = eitherAccount.getRight().toNullable()!.id;
    final eitherDelete =
        await _jurationDao.deleteByContestIdAndJurorId(contestId: contestId, jurorId: accountId);
    return eitherDelete.fold(
      (failure) => Either.left(failure),
      (success) => Either.right(unit),
    );
  }

  @override
  Future<Either<Failure, JurorVotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    return handleDatabaseCall(
      () async {
        // 1. Chiama la funzione RPC.
        //    La funzione restituisce un singolo oggetto JSON, quindi usiamo .single().
        final res = await _supabase.rpc(
          'juror_get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        // 2. Deserializza la mappa JSON ricevuta nel bundle corrispondente.
        return Either.right(JurorVotingSessionProcedureBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  }) async {
    return handleDatabaseCall(
      () async {
        final Stream<Either<Failure, VotingSession?>> stream = _supabase
            .from('voting_sessions')
            .stream(primaryKey: ['id']) // Specifica la chiave primaria della tabella
            .eq('id', votingSessionId) // Filtra per ricevere aggiornamenti solo per questa sessione
            .timeout(Duration(days: 1))
            .map((listOfMaps) {
              // La stream emette una lista di mappe.
              try {
                if (listOfMaps.isEmpty) {
                  // Se la lista è vuota, la sessione è stata probabilmente cancellata.
                  return Either.right(null);
                }
                // Altrimenti, deserializza il primo (e unico) elemento.
                return Either.right(VotingSession.fromJson(listOfMaps.first));
              } catch (e) {
                // In caso di errore di parsing, emetti un Failure.
                return Either.left(Failure(e.toString()));
              }
            });
        return Either.right(stream);
      },
    );
  }

  @override
  Future<Either<Failure, VotingSessionJuror>> getOwnVotingSessionJuration({
    required String votingSessionId,
  }) {
    return handleDatabaseCall(
      () async {
        // Chiama la nuova funzione RPC che abbiamo creato.
        // Usiamo .single() perché ci aspettiamo esattamente un risultato.
        final res = await _supabase.rpc(
          'juror_get_own_voting_session_juror',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        // Deserializza il JSON ricevuto nell'oggetto Dart corrispondente.
        return Either.right(VotingSessionJuror.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> submitVotes({
    required String votingSessionId,
    required List<Map<String,dynamic>> votesPayload,
    required double? jurorLat,
    required double? jurorLon,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('juror_submit_votes', params: {
          'p_voting_session_id': votingSessionId,
          'p_votes_payload': votesPayload,
          'p_juror_lat': jurorLat,
          'p_juror_lon': jurorLon,
        });
        return Either.right(unit);
      },
    );
  }

// @override
// Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests() async {
//   try {
//     final List<Map<String, dynamic>> res =
//         await _supabase.rpc('juror_get_joined_contests');
//     return Either.right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure,ContestDetailsBundle>> getContestDetails({required String contestId}) async {
//   try {
//     final List<Map<String, dynamic>> res = await _supabase
//         .rpc('juror_get_contest_details',params: {'p_contest_id':contestId});
//     return Either.right(ContestDetailsBundle.fromRpcJson(res.first));
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, Unit>> joinContest({
//   required String token,
// }) async {
//   try {
//     await _supabase.rpc('juror_join_contest', params: {
//       'p_token': token,
//     });
//     return Either.right(unit);
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure,Unit>> leaveContest({required String contestId}) async {
//   try {
//     await _supabase.rpc('juror_leave_contest', params: {
//       'p_contest_id' : contestId,
//     });
//     return Either.right(unit);
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, Unit>> jurorSubmitVotes({
//   required String votingSessionId,
//   required String contestId,
//   required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
// }) async {
//   try {
//     final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
//         votesPerParticipantMap.map(
//             (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
//     await _supabase.rpc('juror_submit_votes', params: {
//       'p_voting_session_id': votingSessionId,
//       'p_contest_id': contestId,
//       'p_votes_per_participant_map': votesPerParticipantMapWithIds,
//     });
//     return Either.right(unit);
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
//   required String votingSessionId,
// }) async {
//   try {
//     return Either.right(_supabase
//         .from('voting_sessions')
//         .stream(primaryKey: ['id'])
//         .eq('id', votingSessionId)
//         .timeout(const Duration(hours: 24))
//         .map((rows) {
//           if (rows.isEmpty) {
//             return Either.right(null);
//           }
//           return Either.right(VotingSession.fromJson(rows.first));
//         }));
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
//   required String fullName,
//   required String token,
// }) async {
//   try {
//     final List<Map<String, dynamic>> res = await _supabase.rpc(
//         'juror_access_voting_as_simple_juror',
//         params: {'p_full_name': fullName, 'p_token': token});
//     return Either.right(SimpleJurorAndVotingSessionBundle.fromJson(res.first));
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
//   required String simpleJurorId,
//   required String votingSessionId,
//   required String contestId,
//   required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
// }) async {
//   try {
//     final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
//         votesPerParticipantMap.map(
//             (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
//     await _supabase.rpc('simple_juror_submit_votes', params: {
//       'p_simple_juror_id': simpleJurorId,
//       'p_voting_session_id': votingSessionId,
//       'p_contest_id': contestId,
//       'p_votes_per_participant_map': votesPerParticipantMapWithIds,
//     });
//     return Either.right(unit);
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
//
// @override
// Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
//   required String votingSessionId,
// }) async {
//   try {
//     final List<Map<String, dynamic>> res = await _supabase.rpc(
//         'juror_get_voting_session_procedure_bundle',
//         params: {'p_voting_session_id': votingSessionId});
//     if (res.isEmpty) {
//       return Either.left(Failure('Voting session not found'));
//     }
//     return Either.right(VotingSessionProcedureBundle.fromRpcJson(res.first));
//   } on SocketException {
//     return Either.left(Failure('Network error'));
//   } on PostgrestException catch (e) {
//     return Either.left(Failure(e.message));
//   } catch (e) {
//     return Either.left(Failure());
//   }
// }
}
