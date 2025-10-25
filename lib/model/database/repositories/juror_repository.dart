import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/juror_contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/juror_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/utils/handle_backend_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests();

  Future<Either<Failure, JurorContestDetailsBundle>> getContestDetails({required String contestId});

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

  Future<Either<Failure, Unit>> submitVotes({
    required String votingSessionId,
    required List<Map<String, dynamic>> votesPayload,
    required double? jurorLat,
    required double? jurorLon,
  });

  Future<Either<Failure, VotingSession>> accessVotingAsSimpleJuror({
    required String token,
  });
}

class JurorRepositoryImpl implements JurorRepository {
  final SupabaseClient _supabase;

  JurorRepositoryImpl({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests() async {
    return handleBackendCall(
      () async {
        final List<Map<String, dynamic>> res = await _supabase.rpc('juror_get_joined_contests');
        return Either.right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
      },
    );
  }

  @override
  Future<Either<Failure, JurorContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    return handleBackendCall(
      () async {
        final Map<String, dynamic> res = await _supabase
            .rpc('juror_get_contest_details', params: {'p_contest_id': contestId}).single();
        return Either.right(JurorContestDetailsBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> joinContest({required String token}) async {
    return handleBackendCall(
      () async {
        await _supabase.rpc('juror_join_contest', params: {
          'p_token': token,
        });
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> leaveContest({required String contestId}) async {
    return handleBackendCall(
      () async {
        await _supabase.rpc('juror_leave_contest', params: {
          'p_contest_id': contestId,
        });
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, JurorVotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    return handleBackendCall(
      () async {
        final res = await _supabase.rpc(
          'juror_get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        return Either.right(JurorVotingSessionProcedureBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  }) async {
    return handleBackendCall(
      () async {
        final Stream<Either<Failure, VotingSession?>> stream = _supabase
            .from('voting_sessions')
            .stream(primaryKey: ['id']) // Specifica la chiave primaria della tabella
            .eq('id', votingSessionId) // Filtra per ricevere aggiornamenti solo per questa sessione
            .timeout(const Duration(days: 1))
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
  Future<Either<Failure, Unit>> submitVotes({
    required String votingSessionId,
    required List<Map<String, dynamic>> votesPayload,
    required double? jurorLat,
    required double? jurorLon,
  }) async {
    return handleBackendCall(
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

  @override
  Future<Either<Failure, VotingSession>> accessVotingAsSimpleJuror({
    required String token,
  }) async {
    return handleBackendCall(
      () async {
        final res = await _supabase
            .rpc('juror_access_voting_as_simple_juror', params: {'p_token': token}).single();
        return Either.right(VotingSession.fromJson(res));
      },
    );
  }
}
