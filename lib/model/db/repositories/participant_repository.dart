import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/db/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/db/daos/account_dao.dart';
import 'package:swift_contest/model/db/daos/participation_dao.dart';
import 'package:swift_contest/model/db/daos/work_dao.dart';
import 'package:swift_contest/model/db/entities/work.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ParticipantRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests();

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, Unit>> joinContest({
    required String token,
  });

  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
  });

  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
  });

  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required Work work,
  });
}

class ParticipantRepositoryImpl implements ParticipantRepository {
  final SupabaseClient _supabase;
  final AccountDao _accountDao;
  final ParticipationDao _participationDao;
  final WorkDao _workDao;

  ParticipantRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AccountDao accountDao,
    required ParticipationDao participationDao,
    required WorkDao workDao,
  })  : _supabase = supabaseClient,
        _accountDao = accountDao,
        _participationDao = participationDao,
        _workDao = workDao;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests() async {
    try {
      final List<Map<String, dynamic>> res =
          await _supabase.rpc('get_joined_contests_as_participant');
      return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
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
          await _supabase.rpc('get_contest_details', params: {'p_contest_id': contestId});
      return right(ContestDetailsBundle.fromJson(res.first));
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> joinContest({
    required String token,
  }) async {
    try {
      await _supabase.rpc('participant_join_contest', params: {
        'p_token': token,
      });
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
  }) async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      final accountId = eitherAccount.getRight().toNullable()!.id;
      final eitherDelete = await _participationDao.deleteByContestIdAndParticipantId(
          contestId: contestId, participantId: accountId);
      return eitherDelete.fold(
        (failure) => Either.left(failure),
        (success) => Either.right(unit),
      );
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
  }) async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      final accountId = eitherAccount.getRight().toNullable()!.id;
      final eitherParticipation = await _participationDao.getByContestIdAndParticipantId(
          contestId: contestId, participantId: accountId);
      if (eitherParticipation.isLeft()) {
        return Either.left(eitherParticipation.getLeft().toNullable()!);
      }
      final participationId = eitherParticipation.getRight().toNullable()!.id!;

      final eitherWork =
          await _workDao.getNullableByParticipationId(participationId: participationId);
      return eitherWork.fold(
        (failure) => Either.left(failure),
        (success) => Either.right(eitherWork.getRight().toNullable()),
      );
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required Work work,
  }) async {
    try {
      await _supabase.rpc('submit_work',params: {
        'p_contest_id' : contestId,
        'p_work' : work.toJson(),
      });
      return right(unit);
      // final eitherAccount = await _accountDao.getCurrent();
      // if (eitherAccount.isLeft()) {
      //   return Either.left(eitherAccount.getLeft().toNullable()!);
      // }
      // final accountId = eitherAccount.getRight().toNullable()!.id;
      //
      // final eitherParticipation = await _participationDao.getByContestIdAndParticipantId(
      //     contestId: contestId, participantId: accountId);
      // if (eitherParticipation.isLeft()) {
      //   return Either.left(eitherParticipation.getLeft().toNullable()!);
      // }
      // final participationId = eitherParticipation.getRight().toNullable()!.id!;
      //
      // final eitherCheck =
      //     await _workDao.getNullableByParticipationId(participationId: work.participationId!);
      // if (eitherCheck.isLeft()) {
      //   return Either.left(eitherCheck.getLeft().toNullable()!);
      // }
      // if (eitherCheck.getRight().toNullable() != null) {
      //   return Either.left(Failure('You have already submitted your work'));
      // }
      // work = work.copyWith(participationId: participationId);
      // final eitherSubmit = await _workDao.create(entity: work);
      // if (eitherSubmit.isLeft()) {
      //   return Either.left(eitherSubmit.getLeft().toNullable()!);
      // }
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}

