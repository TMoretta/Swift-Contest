import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/simple_juror_and_voting_session_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class JurorRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests({
    required String jurorId,
  });

  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> joinContest({
    required String jurorId,
    required String token,
  });

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  });

  Future<Either<Failure, Unit>> jurorSubmitVotes({
    required String jurorId,
    required String votingSessionId,
    required String contestId,
    required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, Place?>> getVotingSessionGeoRestrictionPlace({required String placeId});

  Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
    required String fullName,
    required String token,
    String? jurorId,
  });

  Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
    required String simpleJurorId,
    required String votingSessionId,
    required String contestId,
    required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
  });
}

class JurorRepositoryImpl implements JurorRepository {
  final SupabaseClient _supabase;

  JurorRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests({
    required String jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('juror_get_joined_contests', params: {'p_juror_id': jurorId});
      return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc('juror_get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting session not found'));
      }
      return right(VotingSessionProcedureBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> joinContest({
    required String jurorId,
    required String token,
  }) async {
    try {
      await _supabase.rpc('juror_join_contest', params: {
        'p_juror_id': jurorId,
        'p_token': token,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('juror_get_contest_details', params: {'p_contest_id': contestId});
      if (res.isEmpty) {
        return left(Failure(message: 'Contest not found'));
      }
      return right(ContestDetailsBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> jurorSubmitVotes({
    required String jurorId,
    required String votingSessionId,
    required String contestId,
    required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
  }) async {
    try {
      final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
          votesPerParticipantMap.map(
              (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
      await _supabase.rpc('juror_submit_votes', params: {
        'p_juror_id': jurorId,
        'p_voting_session_id': votingSessionId,
        'p_contest_id': contestId,
        'p_votes_per_participant_map': votesPerParticipantMapWithIds,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  }) async {
    try {
      return right(_supabase
          .from('voting_sessions')
          .stream(primaryKey: ['id'])
          .eq('id', votingSessionId)
          .timeout(const Duration(hours: 24))
          .map((rows) {
            if (rows.isEmpty) {
              return right(null);
            }
            return right(VotingSession.fromJson(rows.first));
          }));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Place?>> getVotingSessionGeoRestrictionPlace(
      {required String placeId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('juror_get_voting_session_geores_place', params: {'p_place_id': placeId});
      if (res.isEmpty) {
        return left(Failure(message: 'Place not found'));
      }
      return right(Place.fromJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, SimpleJurorAndVotingSessionBundle>> accessVotingAsSimpleJuror({
    required String fullName,
    required String token,
    String? jurorId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'juror_access_voting_as_simple_juror',
          params: {'p_full_name': fullName, 'p_token': token, 'p_juror_id': jurorId});
      return right(SimpleJurorAndVotingSessionBundle.fromJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> simpleJurorSubmitVotes({
    required String simpleJurorId,
    required String votingSessionId,
    required String contestId,
    required Map<VotingSessionParticipation, Map<VotingFormField, double>> votesPerParticipantMap,
  }) async {
    try {
      final Map<String, Map<String, double>> votesPerParticipantMapWithIds =
          votesPerParticipantMap.map(
              (key, value) => MapEntry(key.id, value.map((key, value) => MapEntry(key.id, value))));
      await _supabase.rpc('simple_juror_submit_votes', params: {
        'p_simple_juror_id': simpleJurorId,
        'p_voting_session_id': votingSessionId,
        'p_contest_id': contestId,
        'p_votes_per_participant_map': votesPerParticipantMapWithIds,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
