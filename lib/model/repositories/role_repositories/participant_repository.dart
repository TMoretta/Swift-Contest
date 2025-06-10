import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ParticipantRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests({
    required String participantId,
  });

  Future<Either<Failure, Unit>> joinContest({
    required String participantId,
    required String token,
  });

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  });

  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
    required String participantId,
  });
}

class ParticipantRepositoryImpl implements ParticipantRepository {
  final SupabaseClient _supabase;

  ParticipantRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests({
    required String participantId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('participant_get_joined_contests', params: {'p_participant_id': participantId});
      return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> joinContest({
    required String participantId,
    required String token,
  }) async {
    try {
      await _supabase.rpc('participant_join_contest', params: {
        'p_participant_id': participantId,
        'p_token': token,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('participant_get_contest_details', params: {'p_contest_id': contestId});
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
  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
    required String participantId,
  }) async {
    try {
      final Map<String, dynamic>? res =
          await _supabase.rpc('participant_get_submitted_work', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
      });
      return right((res != null) ? Work.fromJson(res) : null);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
