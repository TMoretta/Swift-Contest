import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class VotingSessionRepository {
  Future<Either<Failure, VotingSession>> createVotingSession({
    required VotingSession votingSession,
  });

  Future<Either<Failure, VotingSession>> updateVotingSession({
    required VotingSession votingSession,
  });

  Future<Either<Failure, VotingSession>> deleteVotingSessionById({required String id});

  Future<Either<Failure, VotingSession?>> getVotingSessionById({required String id});

  Future<Either<Failure, List<VotingSession>>> getVotingSessionsByContestId({
    required String contestId,
  });

  Future<Either<Failure, VotingSession?>> getVotingSessionByToken({required String token});
}

//* Implementation
class VotingSessionRepositoryImpl implements VotingSessionRepository {
  final SupabaseClient _supabase;

  VotingSessionRepositoryImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  @override
  Future<Either<Failure, VotingSession>> createVotingSession({
    required VotingSession votingSession,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('create_voting_session', params: {'p_voting_session': votingSession.toJson()});
      return right(VotingSession.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession>> updateVotingSession({
    required VotingSession votingSession,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('update_voting_session', params: {'p_voting_session': votingSession.toJson()});
      return right(VotingSession.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession>> deleteVotingSessionById({required String id}) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('delete_voting_session_by_id', params: {'p_id': id});
      return right(VotingSession.fromJson(res));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession?>> getVotingSessionById({required String id}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_by_id', params: {'p_id': id});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSession.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<VotingSession>>> getVotingSessionsByContestId({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('get_voting_sessions_by_contest_id', params: {'p_contest_id': contestId});
      return right(res.map((e) => VotingSession.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession?>> getVotingSessionByToken({required String token}) async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_voting_session_by_token', params: {'p_token': token});
      if (res.isEmpty) {
        return right(null);
      }
      return right(VotingSession.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
