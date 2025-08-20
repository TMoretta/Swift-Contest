import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/bundles/organizer_contest_details_bundle.dart';
import 'package:swift_contest/model/database/bundles/organizer_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_form_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_juror_result_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_jury_result_bundle.dart';
import 'package:swift_contest/model/database/bundles/voting_session_result_bundle.dart';
import 'package:swift_contest/model/database/entities/contest.dart';
import 'package:swift_contest/model/database/entities/juration.dart';
import 'package:swift_contest/model/database/entities/juror_invitation.dart';
import 'package:swift_contest/model/database/entities/jury.dart';
import 'package:swift_contest/model/database/entities/participant_invitation.dart';
import 'package:swift_contest/model/database/entities/participation.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class OrganizerRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests();

  Future<Either<Failure, OrganizerContestDetailsBundle>> getContestDetails({
    required String contestId,
  });

  Future<Either<Failure, Contest>> createContest({
    required Contest contest,
    required Place place,
    required List<XFile> images,
  });

  Future<Either<Failure, Unit>> updateContest({
    required Contest contest,
    required Place place,
    required List<XFile>? images,
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
    required String? name,
    required String? description,
  });

  Future<Either<Failure, JuryBundle>> getJuryBundle({required String juryId});

  Future<Either<Failure, VotingFormBundle>> getVotingFormBundle({required String votingFormId});

  Future<Either<Failure, VotingSession>> startVotingSession({
    // perchè dal client decido quali partecipanti includo
    required List<Participation> participations,
    //perchè posso aggiungere esclusioni per cui un certo giurato non può votare un certo partecipante,
    //poi diventa una voting_session_exclusion
    required List<({Juration juration, Participation participation})> exclusions,
    // la voting session con alcuni dati come il place se non null
    required VotingSession votingSession,
    required Place? geoResPlace,
  });

  Future<Either<Failure, OrganizerVotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  });

  Future<Either<Failure, Stream<Either<Failure, VotingSession?>>>> getVotingSessionStream({
    required String votingSessionId,
  });

  Future<Either<Failure, Unit>> endVotingSession({required String votingSessionId});

  Future<Either<Failure, Unit>> cancelVotingSession({required String votingSessionId});

  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultDetails({
    required String votingSessionId,
  });

  Future<Either<Failure, VotingSessionJuryResultBundle>> getVotingSessionJuryResultDetails({
    required String votingSessionJuryId,
  });

  Future<Either<Failure, VotingSessionJurorResultBundle>> getVotingSessionJurorResultDetails({
    required String votingSessionJurorId,
  });

  Future<Either<Failure, Unit>> updateVotingSessionName({
    required String votingSessionId,
    required String name,
  });

  Future<Either<Failure, Unit>> publishRanking({
    required String contestId,
    required PlatformFile file,
  });

  Future<Either<Failure, Unit>> unpublishRanking({
    required String contestRankingId,
  });

  Future<Either<Failure, String>> regenerateJuryToken({required String juryId});
}

class OrganizerRepositoryImpl implements OrganizerRepository {
  final SupabaseClient _supabase;

  OrganizerRepositoryImpl({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<HomeContestBundle>>> getCreatedContests() async {
    return handleDatabaseCall(
      () async {
        final List<Map<String, dynamic>> res =
            await _supabase.rpc('organizer_get_created_contests');
        return Either.right(res.map((e) => HomeContestBundle.fromJson(e)).toList(growable: false));
      },
    );
  }

  @override
  Future<Either<Failure, OrganizerContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase
            .rpc('organizer_get_contest_details', params: {'p_contest_id': contestId}).single();
        return Either.right(OrganizerContestDetailsBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Contest>> createContest({
    required Contest contest,
    required Place place,
    required List<XFile> images,
  }) async {
    return handleDatabaseCall<Contest>(() async {
      final List<Map<String, String>> imagesPayload = [];
      for (final imageFile in images) {
        final fileBytes = await imageFile.readAsBytes();
        final fileBase64 = base64Encode(fileBytes);

        imagesPayload.add({
          'name': imageFile.name,
          'content': fileBase64,
        });
      }

      final result = await _supabase.functions.invoke(
        'organizer-create-contest',
        body: {
          'contest': contest.toJson(),
          'place': place.toJson(),
          'images': imagesPayload,
        },
      );

      return Either.right(Contest.fromJson(result.data));
    });
  }

  @override
  Future<Either<Failure, Unit>> updateContest({
    required Contest contest,
    required Place place,
    required List<XFile>? images,
  }) async {
    return handleDatabaseCall(
      () async {
        // Prepara il corpo base della richiesta
        final Map<String, dynamic> body = {
          'place': place.toJson(),
          'contest': contest.toJson(),
        };

        // Gestisce le immagini solo se la lista non è nulla e non è vuota
        if (images != null && images.isNotEmpty) {
          final List<Map<String, String>> imagesPayload = [];
          for (final imageFile in images) {
            final fileBytes = await imageFile.readAsBytes();
            final fileBase64 = base64Encode(fileBytes);
            imagesPayload.add({
              'name': imageFile.name,
              'content': fileBase64,
            });
          }
          // Aggiunge il payload delle immagini al corpo
          body['images'] = imagesPayload;
        }

        await _supabase.functions.invoke(
          'organizer-update-contest',
          body: body, // Invia il corpo costruito
        );

        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteContest({required String contestId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('organizer_delete_contest', params: {'p_contest_id': contestId});
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
        final res = await _supabase
            .rpc('organizer_create_jury', params: {'p_jury': jury.toJson()}).single();
        return Either.right(Jury.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteJurorInvitation({required String jurorInvitationId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('organizer_delete_juror_invitation',
            params: {'p_juror_invitation_id': jurorInvitationId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> deleteJury({required String juryId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc('organizer_delete_jury', params: {'p_jury_id': juryId});
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
        await _supabase.rpc('organizer_delete_participant_invitation',
            params: {'p_participant_invitation_id': participantInvitationId});
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
        final Map<String, dynamic> res = await _supabase.rpc('organizer_get_participation_bundle',
            params: {'p_participation_id': participationId}).single();
        return Either.right(ParticipationBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> inviteJuror({required JurorInvitation jurorInvitation}) async {
    return handleDatabaseCall(
      () async {
        final res = await _supabase.functions
            .invoke('organizer-invite-juror', body: {'juror_invitation': jurorInvitation.toJson()});
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
        final res = await _supabase.functions.invoke('organizer-invite-participant',
            body: {'participant_invitation': participantInvitation.toJson()});
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
        await _supabase.rpc('organizer_remove_juror', params: {'p_juration_id': jurationId});
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> removeParticipant({required String participationId}) async {
    return handleDatabaseCall(
      () async {
        await _supabase
            .rpc('organizer_remove_participant', params: {'p_participation_id': participationId});
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
        final res = await _supabase.rpc(
          'organizer_update_jury_name',
          params: {
            'p_jury_id': juryId,
            'p_name': name,
          },
        ).single();
        return Either.right(Jury.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> updateVotingForm({
    required String votingFormId,
    required List<VotingFormField> votingFormFields,
    required String? name,
    required String? description,
  }) async {
    return handleDatabaseCall(
      () async {
        final votingFormFieldsJson =
            votingFormFields.map((e) => e.toJson()).toList(growable: false);
        await _supabase.rpc('organizer_update_voting_form', params: {
          'p_voting_form_id': votingFormId,
          'p_name': name,
          'p_description': description,
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
        final res = await _supabase
            .rpc('organizer_get_jury_bundle', params: {'p_jury_id': juryId}).single();
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
        final res = await _supabase.rpc('organizer_get_voting_form_bundle',
            params: {'p_voting_form_id': votingFormId}).single();

        return Either.right(VotingFormBundle.fromJson(res));
      },
    );
  }

  @override
  Future<Either<Failure, VotingSession>> startVotingSession({
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
          'organizer_start_voting_session',
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
  Future<Either<Failure, OrganizerVotingSessionProcedureBundle>> getVotingSessionProcedureBundle({
    required String votingSessionId,
  }) async {
    return handleDatabaseCall(
      () async {
        // 1. Chiama la funzione RPC.
        //    La funzione restituisce un singolo oggetto JSON, quindi usiamo .single().
        final res = await _supabase.rpc(
          'organizer_get_voting_session_procedure_bundle',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        // 2. Deserializza la mappa JSON ricevuta nel bundle corrispondente.
        return Either.right(OrganizerVotingSessionProcedureBundle.fromJson(res));
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

  @override
  Future<Either<Failure, Unit>> updateVotingSessionName({
    required String votingSessionId,
    required String name,
  }) async {
    return handleDatabaseCall(
      () async {
        await _supabase.rpc(
          'organizer_update_voting_session_name',
          params: {
            'p_voting_session_id': votingSessionId,
            'p_name': name,
          },
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, VotingSessionResultBundle>> getVotingSessionResultDetails({
    required String votingSessionId,
  }) {
    return handleDatabaseCall(
      () async {
        final result = await _supabase.rpc(
          'organizer_get_voting_session_result_bundle',
          params: {'p_voting_session_id': votingSessionId},
        ).single();

        // Restituisce il bundle in caso di successo.
        return Either.right(VotingSessionResultBundle.fromJson(result));
      },
    );
  }

  @override
  Future<Either<Failure, VotingSessionJuryResultBundle>> getVotingSessionJuryResultDetails({
    required String votingSessionJuryId,
  }) async {
    return handleDatabaseCall(
      () async {
        // Esegue la chiamata alla funzione RPC sul database.
        final result = await _supabase.rpc(
          'organizer_get_voting_session_jury_result_bundle',
          params: {'p_voting_session_jury_id': votingSessionJuryId},
        ).single();

        // Restituisce il bundle in caso di successo.
        return Either.right(VotingSessionJuryResultBundle.fromJson(result));
      },
    );
  }

  @override
  Future<Either<Failure, VotingSessionJurorResultBundle>> getVotingSessionJurorResultDetails({
    required String votingSessionJurorId,
  }) async {
    return handleDatabaseCall(
      () async {
        // Esegue la chiamata alla funzione RPC sul database.
        final result = await _supabase.rpc(
          'organizer_get_voting_session_juror_result_bundle',
          params: {'p_voting_session_juror_id': votingSessionJurorId},
        ).single();

        // Restituisce il bundle in caso di successo.
        return Either.right(VotingSessionJurorResultBundle.fromJson(result));
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> publishRanking({
    required String contestId,
    required PlatformFile file,
  }) async {
    return handleDatabaseCall(
      () async {
        final String fileBase64 = base64Encode(file.bytes!);

        await _supabase.functions.invoke(
          'organizer-publish-ranking',
          body: {
            'contest_id': contestId,
            'file_name': file.name,
            'file': fileBase64,
          },
        );

        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> unpublishRanking({required String contestRankingId}) {
    return handleDatabaseCall(
      () async {
        await _supabase.functions.invoke(
          'organizer-unpublish-ranking',
          body: {
            'contest_ranking_id': contestRankingId,
          },
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, String>> regenerateJuryToken({required String juryId}) async {
    return handleDatabaseCall(
      () async {
        final newToken = await _supabase.rpc(
          'organizer_regenerate_jury_token',
          params: {'p_jury_id': juryId},
        );
        // The RPC now returns the new token as a string.
        return Either.right(newToken as String);
      },
    );
  }
}
