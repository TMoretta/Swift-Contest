import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
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

  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
    required String participantId,
  });

  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
    required String fileUrl,
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
    required String participantId,
  }) async {
    try {
      await _supabase.rpc('participant_leave_contest', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
      });
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
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
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('participant_get_submitted_work', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
      });
      if (res.isEmpty) {
        return right(null);
      }
      return right(Work.fromJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required String participantId,
    required String name,
    required String description,
    required List<String> imagesUrls,
    required String fileUrl,
  }) async {
    try {
      await _supabase.rpc('participant_submit_work', params: {
        'p_contest_id': contestId,
        'p_participant_id': participantId,
        'p_name': name,
        'p_description': description,
        'p_images_urls': imagesUrls,
        'p_file_url': fileUrl,
      });
      return right(unit);
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
