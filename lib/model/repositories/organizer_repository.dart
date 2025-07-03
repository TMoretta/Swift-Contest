import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
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

  Future<Either<Failure, Unit>> createContest({
    required ContestModel contest,
    required PlaceModel place,
  });

  Future<Either<Failure, Unit>> editContest({
    required String contestId,
    required String name,
    required String description,
    required DateTime dateTime,
    required Place place,
    required DateTime worksSubmissionStart,
    required DateTime worksSubmissionEnd,
    required List<String> imagesUrls,
  });

  Future<Either<Failure, ParticipationBundle?>> getParticipationBundle({
    required String participationId,
  });

  Future<Either<Failure, Unit>> setContestStatusAsActive({required String contestId});

  Future<Either<Failure, Unit>> setContestStatusAsTerminated({required String contestId});

  Future<Either<Failure, Unit>> sendInvite({required InvitationModel invitation});

  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormFieldModel> votingFormFields,
  });

  Future<Either<Failure, Unit>> deleteInvitation({required String invitationId});

  Future<Either<Failure, Unit>> removeParticipant({
    required String participationId,
  });

  Future<Either<Failure, Unit>> removeJuror({
    required String jurationId,
  });

  Future<Either<Failure, VotingSession>> initVotingSession({
    required List<VotingFormFieldModel> votingFormFields,
    required PlaceModel? geoRestrictionPlace,
    required VotingSessionModel votingSession,
    required List<VotingSessionParticipationModel> votingSessionParticipations,
    required List<VotingSessionJurationModel> votingSessionJurations,
    required List<VotingSessionExclusionModel> votingSessionExclusions,
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

  Future<Either<Failure, Unit>> updateVotingSessionName({
    required String votingSessionId,
    required String name,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> deleteContest({required String contestId});

// Future<Either<Failure, JurorVotesRawBundle>> getVotingSessionJurorVotes({
//   required String votingSessionId,
// });
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> createContest({
    required ContestModel contest,
    required PlaceModel place,
  }) async {
    try {
      await _supabase.rpc('organizer_create_contest', params: {
        'p_contest': contest.toJson(),
        'p_place': place.toJson(),
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
  Future<Either<Failure, Unit>> editContest({
    required String contestId,
    required String name,
    required String description,
    required DateTime dateTime,
    required Place place,
    required DateTime worksSubmissionStart,
    required DateTime worksSubmissionEnd,
    required List<String> imagesUrls,
  }) async {
    try {
      await _supabase.rpc('organizer_edit_contest', params: {
        'p_contest_id': contestId,
        'p_name': name,
        'p_description': description,
        'p_date_time': dateTime.toUtc().toIso8601String(),
        'p_place': place.toJson(),
        'p_works_submission_start': worksSubmissionStart.toUtc().toIso8601String(),
        'p_works_submission_end': worksSubmissionEnd.toUtc().toIso8601String(),
        'p_images_urls': imagesUrls,
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
  Future<Either<Failure, ParticipationBundle?>> getParticipationBundle({
    required String participationId,
  }) async {
    try {
      final List<Map<String, dynamic>> res = await _supabase.rpc('organizer_get_participation_bundle', params: {
        'p_participation_id': participationId,
      });
      if(res.isEmpty) {
        return right(null);
      }
      return right(ParticipationBundle.fromJson(res.first));
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> setContestStatusAsActive({required String contestId}) async {
    try {
      await _supabase.rpc('organizer_set_contest_status_as_active', params: {
        'p_contest_id': contestId,
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
  Future<Either<Failure, Unit>> setContestStatusAsTerminated({required String contestId}) async {
    try {
      await _supabase.rpc('organizer_set_contest_status_as_terminated', params: {
        'p_contest_id': contestId,
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
  Future<Either<Failure, Unit>> sendInvite({
    required InvitationModel invitation,
  }) async {
    try {
      final FunctionResponse res = await _supabase.functions
          .invoke('organizer-send-invite', body: {'p_invitation': invitation.toJson()});
      if (res.status != 200) {
        final serverMessage = res.data is String ? res.data as String : 'Failed to send invite';

        return left(Failure(message: serverMessage));
      }
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
  Future<Either<Failure, Unit>> deleteInvitation({required String invitationId}) async {
    try {
      await _supabase.rpc('organizer_delete_invitation', params: {
        'p_invitation_id': invitationId,
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
  Future<Either<Failure, Unit>> removeParticipant({
    required String participationId,
  }) async {
    try {
      await _supabase.rpc('organizer_remove_participant', params: {
        'p_participation_id': participationId,
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
  Future<Either<Failure, Unit>> removeJuror({
    required String jurationId,
  }) async {
    try {
      await _supabase.rpc('organizer_remove_juror', params: {
        'p_juration_id': jurationId,
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
  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormFieldModel> votingFormFields,
  }) async {
    try {
      await _supabase.rpc('organizer_update_voting_form_fields', params: {
        'p_voting_form_id': votingFormId,
        'p_voting_form_fields': votingFormFields.map((e) => e.toJson()).toList(growable: false),
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
  Future<Either<Failure, VotingSession>> initVotingSession({
    required List<VotingFormFieldModel> votingFormFields,
    required PlaceModel? geoRestrictionPlace,
    required VotingSessionModel votingSession,
    required List<VotingSessionParticipationModel> votingSessionParticipations,
    required List<VotingSessionJurationModel> votingSessionJurations,
    required List<VotingSessionExclusionModel> votingSessionExclusions,
  }) async {
    try {
      final Map<String, dynamic> res =
          await _supabase.rpc('organizer_init_voting_session', params: {
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVotingSessionName({
    required String votingSessionId,
    required String name,
  }) async {
    try {
      await _supabase.rpc('organizer_update_voting_session_name', params: {
        'p_voting_session_id': votingSessionId,
        'p_name': name,
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
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
    } on SocketException {
      return left(Failure(message: 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

// @override
// Future<Either<Failure, JurorVotesRawBundle>> getVotingSessionJurorVotes({
//   required String votingSessionId,
// }) async {
//   try {
//     final List<Map<String, dynamic>> res = await _supabase
//         .rpc('organizer_get_voting_session_raw_juror_votes', params: {'p_voting_session_id': votingSessionId});
//     if (res.isEmpty) {
//       return left(Failure(message: 'No votes found'));
//     }
//     return right(JurorVotesRawBundle.fromRpcJson(res.first));
//   } on PostgrestException catch (e) {
//     return left(Failure(message: e.message));
//   } catch (e) {
//     return left(Failure());
//   }
// }
}
