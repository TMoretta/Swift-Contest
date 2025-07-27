import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/db/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/db/bundles/jury_bundle.dart';
import 'package:swift_contest/model/db/bundles/participation_bundle.dart';
import 'package:swift_contest/model/db/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/db/daos/account_dao.dart';
import 'package:swift_contest/model/db/daos/contest_dao.dart';
import 'package:swift_contest/model/db/daos/juration_dao.dart';
import 'package:swift_contest/model/db/daos/juror_invitation_dao.dart';
import 'package:swift_contest/model/db/daos/jury_dao.dart';
import 'package:swift_contest/model/db/daos/participant_invitation_dao.dart';
import 'package:swift_contest/model/db/daos/participation_dao.dart';
import 'package:swift_contest/model/db/daos/place_dao.dart';
import 'package:swift_contest/model/db/daos/profile_dao.dart';
import 'package:swift_contest/model/db/daos/voting_form_dao.dart';
import 'package:swift_contest/model/db/daos/voting_form_field_dao.dart';
import 'package:swift_contest/model/db/daos/voting_session_dao.dart';
import 'package:swift_contest/model/db/entities/contest.dart';
import 'package:swift_contest/model/db/entities/juror_invitation.dart';
import 'package:swift_contest/model/db/entities/jury.dart';
import 'package:swift_contest/model/db/entities/participant_invitation.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/db/entities/voting_form.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class OrganizerRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests();

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, Unit>> createContest({
    required Contest contest,
    required Place place,
  });

  Future<Either<Failure, Unit>> updateContest({
    required Contest contest,
    required Place place,
  });

  Future<Either<Failure, Unit>> deleteContest({required String contestId});

  Future<Either<Failure, ParticipationBundle>> getParticipationBundle({
    required String participationId,
  });

  Future<Either<Failure, Unit>> inviteParticipant({
    required ParticipantInvitation participantInvitation,
  });

  Future<Either<Failure, Unit>> inviteJuror({
    required JurorInvitation jurorInvitation,
  });

  Future<Either<Failure, Unit>> deleteParticipantInvitation({
    required String participantInvitationId,
  });

  Future<Either<Failure, Unit>> deleteJurorInvitation({
    required String jurorInvitationId,
  });

  Future<Either<Failure, Unit>> removeParticipant({
    required String participationId,
  });

  Future<Either<Failure, Unit>> removeJuror({required String jurationId});

  Future<Either<Failure, Jury>> createJury({required Jury jury});

  Future<Either<Failure, Jury>> updateJuryName({
    required String juryId,
    required String name,
  });

  Future<Either<Failure, Unit>> deleteJury({
    required String juryId,
  });

  Future<Either<Failure, Unit>> updateVotingForm({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
  });

  Future<Either<Failure, JuryBundle>> getJuryBundle({required String juryId});

  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({required String votingFormId});

// Future<Either<Failure, VotingSession>> initVotingSession({
//   required List<VotingFormFieldModel> votingFormFields,
//   required PlaceModel? geoRestrictionPlace,
//   required VotingSessionModel votingSession,
//   required List<VotingSessionParticipationModel> votingSessionParticipations,
//   required List<VotingSessionJurationModel> votingSessionJurations,
//   required List<VotingSessionExclusionModel> votingSessionExclusions,
// });
//
// Future<Either<Failure, Unit>> startVotingSession({
//   required String votingSessionId,
// });
//
// Future<Either<Failure, Unit>> endVotingSession({
//   required String votingSessionId,
// });
//
// Future<Either<Failure, Unit>> cancelVotingSession({
//   required String votingSessionId,
// });
//
// Future<Either<Failure, Unit>> updateVotingSessionName({
//   required String votingSessionId,
//   required String name,
// });
//
// Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
//   required String votingSessionId,
// });
//
// Future<Either<Failure, VotingFormBundle>> getContestVotingFormBundle({
//   required String votingFormId,
// });
//
// Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
//   required String votingSessionId,
// });
//
// Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
//   required String votingSessionId,
// });
}

class OrganizerRepositoryImpl implements OrganizerRepository {
  final SupabaseClient _supabase;
  final AccountDao _accountDao;
  final ContestDao _contestDao;
  final ProfileDao _profileDao;
  final PlaceDao _placeDao;
  final ParticipationDao _participationDao;
  final JurationDao _jurationDao;
  final JuryDao _juryDao;
  final VotingSessionDao _votingSessionDao;
  final JurorInvitationDao _jurorInvitationDao;
  final ParticipantInvitationDao _participantInvitationDao;
  final VotingFormDao _votingFormDao;
  final VotingFormFieldDao _votingFormFieldDao;

  OrganizerRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AccountDao accountDao,
    required ContestDao contestDao,
    required ProfileDao profileDao,
    required PlaceDao placeDao,
    required ParticipationDao participationDao,
    required JurationDao jurationDao,
    required JuryDao juryDao,
    required VotingSessionDao votingSessionDao,
    required JurorInvitationDao jurorInvitationDao,
    required ParticipantInvitationDao participantInvitationDao,
    required VotingFormDao votingFormDao,
    required VotingFormFieldDao votingFormFieldDao,
  })  : _supabase = supabaseClient,
        _accountDao = accountDao,
        _contestDao = contestDao,
        _profileDao = profileDao,
        _placeDao = placeDao,
        _participationDao = participationDao,
        _juryDao = juryDao,
        _jurationDao = jurationDao,
        _votingSessionDao = votingSessionDao,
        _jurorInvitationDao = jurorInvitationDao,
        _participantInvitationDao = participantInvitationDao,
        _votingFormDao = votingFormDao,
        _votingFormFieldDao = votingFormFieldDao;

  String get accountId => _supabase.auth.currentUser?.id ?? '';

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests() async {
    try {
      final List<Map<String,dynamic>> res = await _supabase.rpc('get_created_contests');
      return Either.right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception catch (_) {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    try {
      final res =
      await _supabase.rpc('get_contest_details', params: {'p_contest_id': contestId});
      return Either.right(ContestDetailsBundle.fromJson(res.first));
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception catch (_) {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> createContest({
    required Contest contest,
    required Place place,
  }) async {
    try {
      await _supabase.rpc('create_contest', params: {'p_contest': contest.toJson(),'p_place': place.toJson()});
      return Either.right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception catch (_) {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateContest(
      {required Contest contest, required Place place}) async {
    try {
      await _supabase.rpc('update_contest', params: {
        'p_contest': contest.toJson(),
        'p_place': place.toJson(),
      });
      return Either.right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteContest({required String contestId}) async {
    try {
      await _contestDao.deleteById(id: contestId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Jury>> createJury({
    required Jury jury,
  }) async {
    try {
      final res = await _supabase
          .rpc('create_jury', params: {'p_jury': jury.toJson()})
          .single();
      return Right(Jury.fromJson(res));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception catch (_) {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJurorInvitation({required String jurorInvitationId}) async {
    try {
      await _jurorInvitationDao.deleteById(id: jurorInvitationId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteJury({required String juryId}) async {
    try {
      await _juryDao.deleteById(id: juryId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on PostgrestException {
      return left(Failure('An unexpected error occurred.'));
    }
    on Exception {
      return left(Failure('An unexpected error occurred.'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteParticipantInvitation(
      {required String participantInvitationId}) async {
    try {
      await _participantInvitationDao.deleteById(id: participantInvitationId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, ParticipationBundle>> getParticipationBundle(
      {required String participationId}) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'get_participation_bundle',
          params: {'p_participation_id': participationId});
      return Either.right(ParticipationBundle.fromJson(res.first));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> inviteJuror({required JurorInvitation jurorInvitation}) async {
    try {
      final res = await _supabase.functions.invoke('invite-juror', body: jurorInvitation.toJson());
      if(res.status!=201) {
        return Either.left(Failure(res.data.toString()));
      }
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> inviteParticipant({
    required ParticipantInvitation participantInvitation,
  }) async {
    try {
      final res = await _supabase.functions.invoke('invite-participant', body: participantInvitation.toJson());
      if(res.status!=201) {
        return Either.left(Failure(res.data.toString()));
      }
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeJuror({required String jurationId}) async {
    try {
      await _jurationDao.deleteById(id: jurationId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeParticipant({required String participationId}) async {
    try {
      await _participationDao.deleteById(id: participationId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Jury>> updateJuryName(
      {required String juryId, required String name}) async {
    try {
      final eitherOldJury = await _juryDao.getById(id: juryId);
      if (eitherOldJury.isLeft()) {
        return left(eitherOldJury.getLeft().toNullable()!);
      }
      final Jury oldJury = eitherOldJury.getRight().toNullable()!;

      final eitherNewJury = await _juryDao.update(entity: oldJury.copyWith(name: name));
      if (eitherNewJury.isLeft()) {
        return left(eitherNewJury.getLeft().toNullable()!);
      }
      return Either.right(eitherNewJury.getRight().toNullable()!);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVotingForm({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
  }) async {
    try {
      final votingFormFieldsJson = votingFormFields.map((e) => e.toJson()).toList(growable: false);
      await _supabase.rpc('update_voting_form',params: {'p_voting_form_id':votingFormId,'p_voting_form_fields': votingFormFieldsJson});
      return Either.right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JuryBundle>> getJuryBundle({required String juryId}) async {
    try {
      final res =
      await _supabase.rpc('get_jury_bundle', params: {'p_jury_id': juryId}).single();
      return Either.right(JuryBundle.fromJson(res));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({
    required String votingFormId,
  }) async {
    try {
      final res = await _supabase
          .rpc('get_voting_form_bundle', params: {'p_voting_form_id': votingFormId})
          .single();

      return Right(VotingFormBundle.fromJson(res));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    } on SocketException {
      return left(Failure('Network error'));
    } on Exception catch (e) {
      return left(Failure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}

// {
// 'contest_bundle' : {'contest' : contest , 'organizer' : profile, 'place' : place},
// 'participations' : [participations],
// 'jurations' : [jurations],
// }
//
// {
// 'contest_bundle' : {'contest' : contest , 'organizer' : profile, 'place' : place},
// 'participations_bundles' : ['participation_bundle' : {'participation' : participation, 'participant' : profile, 'work' : work?}],
// 'participants_invitations' : ['participant_invitation' : participant_invitation],
// 'juries_bundles' : ['jury_bundle' : {'jury' : jury, 'jurations_bundles' : ['juration_bundle' : {'juration' : juration, 'juror' : profile}], 'jurors_invitations' : ['juror_invitation' : juror_invitation], 'voting_form_bundle' : {'voting_form': voting_form, 'voting_form_fields' : ['voting_form_field' : voting_form_field]}}],
// 'voting_sessions' : ['voting_session' : voting_session],
// }
