import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/db/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/db/bundles/jury_bundle.dart';
import 'package:swift_contest/model/db/bundles/participation_bundle.dart';
import 'package:swift_contest/model/db/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/db/bundles/voting_session_procedure_bundle.dart';
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
import 'package:swift_contest/model/db/entities/juration.dart';
import 'package:swift_contest/model/db/entities/juror_invitation.dart';
import 'package:swift_contest/model/db/entities/jury.dart';
import 'package:swift_contest/model/db/entities/participant_invitation.dart';
import 'package:swift_contest/model/db/entities/participation.dart';
import 'package:swift_contest/model/db/entities/place.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/entities/voting_session.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
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

  Future<Either<Failure, VotingSession>> initVotingSession({
    // perchè dal client decido quali partecipanti includo
    required List<Participation> participations,
    //perchè posso aggiungere esclusioni per cui un certo giurato non può votare un certo partecipante,
    //poi diventa una voting_session_exclusion
    required List<({Juration juration, Participation participation})> exclusions,
    // la voting session con alcuni dati come il place se non null
    required VotingSession votingSession,
    required Place? geoResPlace,
  });

  Future<Either<Failure, Unit>> regenerateContestToken({required String contestId});

  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> startVotingSession({
    required String votingSessionId
  });

  Future<Either<Failure, Unit>> advanceVotingSession({required String votingSessionId});

  Future<Either<Failure, Unit>> endVotingSession({
    required String votingSessionId
  });

  Future<Either<Failure, Unit>> cancelVotingSession({
    required String votingSessionId
  });

// Future<Either<Failure, Unit>> updateVotingSessionName({
//   required String votingSessionId,
//   required String name,
// });

// Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultBundle({
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
    return handleDatabaseCall(
      () async {
        final List<Map<String, dynamic>> res = await _supabase.rpc('get_created_contests');
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
        final res = await _supabase.rpc('get_contest_details', params: {'p_contest_id': contestId});
        return Either.right(ContestDetailsBundle.fromJson(res.first));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> createContest({
    required Contest contest,
    required Place place,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('create_contest',
            params: {'p_contest': contest.toJson(), 'p_place': place.toJson()});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateContest({
    required Contest contest,
    required Place place,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('update_contest', params: {
          'p_contest': contest.toJson(),
          'p_place': place.toJson(),
        });
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteContest({required String contestId}) async {
    return handleDatabaseCall(
      () async {
        await _contestDao.deleteById(id: contestId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Jury>> createJury({
    required Jury jury,
  }) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.rpc('create_jury', params: {'p_jury': jury.toJson()}).single();
        return Either.right(Jury.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteJurorInvitation({required String jurorInvitationId}) async {
    return handleDatabaseCall(
      () async {
        await _jurorInvitationDao.deleteById(id: jurorInvitationId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteJury({required String juryId}) async {
    return handleDatabaseCall(
      () async {
        await _juryDao.deleteById(id: juryId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteParticipantInvitation({
    required String participantInvitationId,
  }) async {
    return handleDatabaseCall(
      () async {
        await _participantInvitationDao.deleteById(id: participantInvitationId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, ParticipationBundle>> getParticipationBundle({
    required String participationId,
  }) async {
    return handleDatabaseCall(
      () async {
        final Map<String, dynamic> res = await _supabase
            .rpc('get_participation_bundle', params: {'p_participation_id': participationId}).single();
        return Either.right(ParticipationBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> inviteJuror({required JurorInvitation jurorInvitation}) async {
    return handleDatabaseCall(
      () async {
        final res =
            await _supabase.functions.invoke('invite-juror', body: jurorInvitation.toJson());
        if (res.status != 201) {
          return Either.left(Failure(res.data.toString()));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> inviteParticipant({
    required ParticipantInvitation participantInvitation,
  }) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.functions
            .invoke('invite-participant', body: participantInvitation.toJson());
        if (res.status != 201) {
          return Either.left(Failure(res.data.toString()));
        }
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> removeJuror({required String jurationId}) async {
    return handleDatabaseCall(
      () async {
        await _jurationDao.deleteById(id: jurationId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> removeParticipant({required String participationId}) async {
    return handleDatabaseCall(
      () async {
        await _participationDao.deleteById(id: participationId);
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Jury>> updateJuryName({
    required String juryId,
    required String name,
  }) async {
    return handleDatabaseCall(
      () async {
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
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateVotingForm({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
  }) async {
    return handleDatabaseCall(
      () async {
        final votingFormFieldsJson =
            votingFormFields.map((e) => e.toJson()).toList(growable: false);
        await _supabase.rpc('update_voting_form', params: {
          'p_voting_form_id': votingFormId,
          'p_voting_form_fields': votingFormFieldsJson
        });
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, JuryBundle>> getJuryBundle({required String juryId}) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.rpc('get_jury_bundle', params: {'p_jury_id': juryId}).single();
        return Either.right(JuryBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({
    required String votingFormId,
  }) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase
            .rpc('get_voting_form_bundle', params: {'p_voting_form_id': votingFormId}).single();

        return Either.right(VotingFormBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, VotingSession>> initVotingSession({
    required List<Participation> participations,
    required List<({Juration juration, Participation participation})> exclusions,
    required VotingSession votingSession,
    required Place? geoResPlace,
  }) async {
    return handleDatabaseCall(
      () async {
        // Estrai solo gli ID dei partecipanti.
        final participationsIds = participations.map((p) => p.id!).toList();

        // Converti la lista di esclusioni in un formato JSON che la RPC può capire.
        final exclusionsJson = exclusions
            .map((e) => {
                  'juration_id': e.juration.id,
                  'participation_id': e.participation.id,
                })
            .toList();

        final res = await _supabase.rpc(
          'organizer_init_voting_session',
          params: {
            'p_voting_session': votingSession.toJson(),
            'p_participations_ids': participationsIds,
            'p_exclusions': exclusionsJson,
            'p_geo_res_place': geoResPlace?.toJson(),
          },
        ).single();

        // 3. Deserializza la risposta e restituiscila.
        return Either.right(VotingSession.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> regenerateContestToken({required String contestId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase
            .rpc('organizer_regenerate_contest_token', params: {'p_contest_id': contestId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, VotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    return handleDatabaseCall(
      () async {
        // 1. Chiama la funzione RPC.
        //    La funzione restituisce un singolo oggetto JSON, quindi usiamo .single().
        final res = await _supabase.rpc(
          'get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        // 2. Deserializza la mappa JSON ricevuta nel bundle corrispondente.
        return Either.right(VotingSessionProcedureBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  }) async {
    return handleDatabaseCall(
      () async {
        final Stream<Either<Failure, VotingSession?>> stream = _supabase
            .from('voting_sessions')
            .stream(primaryKey: ['id']) // Specifica la chiave primaria della tabella
            .eq('id', votingSessionId) // Filtra per ricevere aggiornamenti solo per questa sessione
            .timeout(Duration(days: 1))
            .map((listOfMaps) {
              // La stream emette una lista di mappe.
              try {
                if (listOfMaps.isEmpty) {
                  // Se la lista è vuota, la sessione è stata probabilmente cancellata.
                  return Either.right(null);
                }
                // Altrimenti, deserializza il primo (e unico) elemento.
                return Either.right(VotingSession.fromJson(listOfMaps.first));
              } catch (e) {
                // In caso di errore di parsing, emetti un Failure.
                return Either.left(Failure(e.toString()));
              }
            });
        return Either.right(stream);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> startVotingSession({required String votingSessionId}) {
    return handleDatabaseCall(
          () async {
        await _supabase.rpc(
          'organizer_start_voting_session',
          params: {'p_voting_session_id': votingSessionId},
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> advanceVotingSession({required String votingSessionId}) {
    return handleDatabaseCall(
          () async {
        // Chiama la funzione RPC senza aspettarsi un ritorno.
        await _supabase.rpc(
          'organizer_advance_voting_session',
          params: {'p_voting_session_id': votingSessionId},
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> endVotingSession({required String votingSessionId}) {
    // Implementazione simile per chiamare 'organizer_end_voting_session'
    return handleDatabaseCall(
          () async {
        await _supabase.rpc(
          'organizer_end_voting_session',
          params: {'p_voting_session_id': votingSessionId},
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> cancelVotingSession({required String votingSessionId}) {
    // Implementazione simile per chiamare 'organizer_cancel_voting_session'
    return handleDatabaseCall(
          () async {
        await _supabase.rpc(
          'organizer_cancel_voting_session',
          params: {'p_voting_session_id': votingSessionId},
        );
        return Either.right(unit);
      },
    );
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
