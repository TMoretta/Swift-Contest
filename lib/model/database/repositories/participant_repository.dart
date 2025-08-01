import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/daos/account_dao.dart';
import 'package:swift_contest/model/database/daos/participation_dao.dart';
import 'package:swift_contest/model/database/daos/work_dao.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
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
    return handleDatabaseCall(
      () async {
        final List<Map<String, dynamic>> res =
            await _supabase.rpc('participant_get_joined_contests');
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
        final Map<String, dynamic> res =
            await _supabase.rpc('user_get_contest_details', params: {'p_contest_id': contestId}).single();
        return Either.right(ContestDetailsBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> joinContest({
    required String token,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('participant_join_contest', params: {
          'p_token': token,
        });
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
  }) async {
    return handleDatabaseCall(
      () async {
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
      },
    );
  }

  @override
  Future<Either<Failure, Work?>> getSubmittedWork({
    required String contestId,
  }) async {
    return handleDatabaseCall(
      () async {
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
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required Work work,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('participant_submit_work', params: {
          'p_contest_id': contestId,
          'p_work': work.toJson(),
        });
        return Either.right(unit);
      },
    );
  }
}
