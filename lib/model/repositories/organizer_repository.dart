import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/trash/juror_votes_raw_bundle.dart';
import 'package:swift_contest/model/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/bundles/voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class OrganizerRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests({
    required String organizerId,
  });

  Future<Either<Failure, ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> createContest({
    required ContestNullable contest,
    required PlaceNullable place,
  });

  Future<Either<Failure, Unit>> sendInvite({required InvitationNullable invitation});

  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormFieldNullable> votingFormFields,
  });

  Future<Either<Failure, Unit>> deleteInvitation({required String invitationId});

  Future<Either<Failure, Unit>> removeParticipant({
    required String participationId,
    required String messageTitle,
    required String messageBody,
  });

  Future<Either<Failure, Unit>> removeJuror({
    required String jurationId,
    required String messageTitle,
    required String messageBody,
  });

  Future<Either<Failure, VotingSession>> initVotingSession({
    required List<VotingFormFieldNullable> votingFormFields,
    required PlaceNullable? geoRestrictionPlace,
    required VotingSessionNullable votingSession,
    required List<VotingSessionParticipationNullable> votingSessionParticipations,
    required List<VotingSessionJurationNullable> votingSessionJurations,
    required List<VotingSessionExclusionNullable> votingSessionExclusions,
  });

  Future<Either<Failure, Unit>> startVotingSession({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> endVotingSession({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> cancelVotingSession({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> editVotingSessionName({
    required String votingSessionId,
    required String name,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> deleteContest({required String contestId});

  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({required String votingFormId});

  Future<Either<Failure, JurorVotesRawBundle>> getVotingSessionJurorVotes({
    required String votingSessionId,
  });
}

class OrganizerRepositoryImpl implements OrganizerRepository {
  final SupabaseClient _supabase;

  OrganizerRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests({
    required String organizerId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('organizer_get_created_contests', params: {'p_organizer_id': organizerId});
      return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
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
          await _supabase.rpc('organizer_get_contest_details', params: {'p_contest_id': contestId});
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
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'organizer_get_voting_session_procedure_bundle',
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
  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc(
          'organizer_get_voting_session_result_bundle',
          params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting session not found'));
      }
      return right(VotingSessionResultBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createContest({
    required ContestNullable contest,
    required PlaceNullable place,
  }) async {
    try {
      await _supabase.rpc('organizer_create_contest', params: {
        'p_contest': contest.toJson(),
        'p_place': place.toJson(),
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendInvite({
    required InvitationNullable invitation,
  }) async {
    try {
      final FunctionResponse res = await _supabase.functions
          .invoke('organizer-send-invite', body: {'p_invitation': invitation.toJson()});
      if (res.status != 200) {
        final serverMessage = res.data is String
            ? res.data as String
            : 'Failed to send invite';

        return left(Failure(message: serverMessage));
      }
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvitation({required String invitationId}) async {
    try {
      await _supabase.rpc('organizer_delete_invitation', params: {
        'p_invitation_id': invitationId,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeParticipant({
    required String participationId,
    required String messageTitle,
    required String messageBody,
  }) async {
    try {
      await _supabase.rpc('organizer_remove_participant', params: {
        'p_participation_id': participationId,
        'p_message_title': messageTitle,
        'p_message_body': messageBody,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeJuror({
    required String jurationId,
    required String messageTitle,
    required String messageBody,
  }) async {
    try {
      await _supabase.rpc('organizer_remove_juror', params: {
        'p_juration_id': jurationId,
        'p_message_title': messageTitle,
        'p_message_body': messageBody,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormFieldNullable> votingFormFields,
  }) async {
    try {
      await _supabase.rpc('organizer_update_voting_form_fields', params: {
        'p_voting_form_id': votingFormId,
        'p_voting_form_fields': votingFormFields.map((e) => e.toJson()).toList(growable: false),
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingSession>> initVotingSession({
    required List<VotingFormFieldNullable> votingFormFields,
    required PlaceNullable? geoRestrictionPlace,
    required VotingSessionNullable votingSession,
    required List<VotingSessionParticipationNullable> votingSessionParticipations,
    required List<VotingSessionJurationNullable> votingSessionJurations,
    required List<VotingSessionExclusionNullable> votingSessionExclusions,
  }) async {
    try {
      final Map<String,dynamic> res = await _supabase.rpc('organizer_init_voting_session', params: {
        'p_voting_form_fields': votingFormFields.map((e) => e.toJson()).toList(growable: false),
        'p_geores_place': geoRestrictionPlace?.toJson(),
        'p_voting_session': votingSession.toJson(),
        'p_voting_session_participations':
            votingSessionParticipations.map((e) => e.toJson()).toList(growable: false),
        'p_voting_session_jurations':
            votingSessionJurations.map((e) => e.toJson()).toList(growable: false),
        'p_voting_session_exclusions':
            votingSessionExclusions.map((e) => e.toJson()).toList(growable: false),
      });
      return right(VotingSession.fromJson(res));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> startVotingSession({
    required String votingSessionId,
  }) async {
    try {
      await _supabase.rpc('organizer_start_voting_session', params: {
        'p_voting_session_id': votingSessionId,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> endVotingSession({
    required String votingSessionId,
  }) async {
    try {
      await _supabase.rpc('organizer_end_voting_session', params: {
        'p_voting_session_id': votingSessionId,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelVotingSession({
    required String votingSessionId,
  }) async {
    try {
      await _supabase.rpc('organizer_cancel_voting_session', params: {
        'p_voting_session_id': votingSessionId,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> editVotingSessionName({
    required String votingSessionId,
    required String name,
  }) async {
    try {
      await _supabase.rpc('organizer_edit_voting_session_name', params: {
        'p_voting_session_id': votingSessionId,
        'p_name': name,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
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
  Future<Either<Failure, Unit>> deleteContest({required String contestId}) async {
    try {
      await _supabase.rpc('organizer_delete_contest', params: {
        'p_contest_id': contestId,
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({
    required String votingFormId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('organizer_get_voting_form_bundle', params: {'p_voting_form_id': votingFormId});
      if (res.isEmpty) {
        return left(Failure(message: 'Voting form not found'));
      }
      return right(VotingFormBundle.fromJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, JurorVotesRawBundle>> getVotingSessionJurorVotes({
    required String votingSessionId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase
          .rpc('organizer_get_voting_session_raw_juror_votes', params: {'p_voting_session_id': votingSessionId});
      if (res.isEmpty) {
        return left(Failure(message: 'No votes found'));
      }
      return right(JurorVotesRawBundle.fromRpcJson(res.first));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
