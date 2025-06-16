import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/data_models/contest.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/model/data_models/voting_session_exclusion.dart';
import 'package:swift_contest/model/data_models/voting_session_juration.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class OrganizerRepository {
  Future<Either<Failure,List<HomeContestBundle>>> getCreatedContests({required String organizerId});

  Future<Either<Failure,ContestDetailsBundle>> getContestDetails({required String contestId});

  Future<Either<Failure, Unit>> createContest({
    required Contest contest,
    required Place place,
    required VotingForm votingForm,
  });

  Future<Either<Failure, Unit>> sendInvite({required Invitation invitation});

  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
  });

  Future<Either<Failure, Unit>> initVotingSession({
    required VotingForm votingForm,
    required List<VotingFormField> votingFormFields,
    required Place? geoRestrictionPlace,
    required VotingSession votingSession,
    required List<VotingSessionParticipation> votingSessionParticipations,
    required List<VotingSessionJuration> votingSessionJurations,
    required List<VotingSessionExclusion> votingSessionExclusions,
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


  Future<Either<Failure,Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });
}

class OrganizerRepositoryImpl implements OrganizerRepository {
  final SupabaseClient _supabase;

  OrganizerRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests({required String organizerId,})async {
    try {
     final List<Map<String,dynamic>> res = await _supabase.rpc('organizer_get_created_contests',params: {'p_organizer_id': organizerId});
     return right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure,ContestDetailsBundle>> getContestDetails({required String contestId,})async {
    try {
      final List<Map<String,dynamic>> res = await _supabase.rpc('organizer_get_contest_details',params: {'p_contest_id': contestId});
      if(res.isEmpty) {
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
  Future<Either<Failure, Unit>> createContest({
    required Contest contest,
    required Place place,
    required VotingForm votingForm,
  }) async {
    try {
      await _supabase.rpc('organizer_create_contest', params: {
        'p_contest': contest.toJson(),
        'p_place': place.toJson(),
        'p_voting_form': votingForm.toJson(),
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
    required Invitation invitation,
  }) async {
    try {
      final FunctionResponse res = await _supabase.functions
          .invoke('organizer-send-invite', body: {'p_invitation': invitation.toJson()});
      if (res.status != 200) {
        return left(Failure(message: 'Failed to send invite'));
      }
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVotingFormFields({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
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
  Future<Either<Failure, Unit>> initVotingSession({
    required VotingForm votingForm,
    required List<VotingFormField> votingFormFields,
    required Place? geoRestrictionPlace,
    required VotingSession votingSession,
    required List<VotingSessionParticipation> votingSessionParticipations,
    required List<VotingSessionJuration> votingSessionJurations,
    required List<VotingSessionExclusion> votingSessionExclusions,
  }) async {
    try {
      await _supabase.rpc('organizer_init_voting_session', params: {
        'p_voting_form': votingForm.toJson(),
        'p_voting_form_fields': votingFormFields.map((e) => e.toJson()).toList(growable: false),
        'p_place' : geoRestrictionPlace?.toJson(),
        'p_voting_session' : votingSession.toJson(),
        'p_voting_session_participations' : votingSessionParticipations.map((e) => e.toJson()).toList(growable: false),
        'p_voting_session_jurations' : votingSessionJurations.map((e) => e.toJson()).toList(growable: false),
        'p_voting_session_exclusions' : votingSessionExclusions.map((e) => e.toJson()).toList(growable: false),
      });
      return right(unit);
    } on PostgrestException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> startVotingSession({required String votingSessionId,}) async{
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
  Future<Either<Failure, Unit>> endVotingSession({required String votingSessionId,})async {
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
  Future<Either<Failure, Unit>> cancelVotingSession({required String votingSessionId,}) async {
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
  Future<Either<Failure,Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
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


}
