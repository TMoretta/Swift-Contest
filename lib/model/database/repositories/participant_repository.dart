import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/database/bundles/home_contest_bundle.dart';
import 'package:swift_contest/model/database/bundles/participant_contest_details_bundle.dart';
import 'package:swift_contest/model/database/entities/work.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class ParticipantRepository {
  Future<Either<Failure, List<HomeContestBundle>>> getJoinedContests();

  Future<Either<Failure, ParticipantContestDetailsBundle>> getContestDetails({
    required String contestId,
  });

  Future<Either<Failure, Unit>> joinContest({
    required String token,
  });

  Future<Either<Failure, Unit>> leaveContest({
    required String contestId,
  });

  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required Work work,
    required List<XFile> images,
    required PlatformFile file,
  });
}

class ParticipantRepositoryImpl implements ParticipantRepository {
  final SupabaseClient _supabase;

  ParticipantRepositoryImpl({
    required SupabaseClient supabaseClient,
  }) : _supabase = supabaseClient;

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
  Future<Either<Failure, ParticipantContestDetailsBundle>> getContestDetails({
    required String contestId,
  }) async {
    return handleDatabaseCall(
      () async {
        final Map<String, dynamic> res = await _supabase
            .rpc('participant_get_contest_details', params: {'p_contest_id': contestId}).single();
        return Either.right(ParticipantContestDetailsBundle.fromJson(res));
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
        await _supabase.functions.invoke(
          'participant-leave-contest',
          body: {'contestId': contestId},
        );
        return Either.right(unit);
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> submitWork({
    required String contestId,
    required Work work,
    required List<XFile> images,
    required PlatformFile file,
  }) async {
    return handleDatabaseCall(
      () async {
        final List<Map<String, String>> imagesPayload = [];
        for (final imageFile in images) {
          final imageBytes = await imageFile.readAsBytes();
          final imageBase64 = base64Encode(imageBytes);

          imagesPayload.add({
            'name': imageFile.name,
            'content': imageBase64,
          });
        }

        Map<String,String> filePayload = {
          'name': file.name,
          'content': base64Encode(file.bytes!),
        };

        await _supabase.functions.invoke(
          'participant-submit-work',
          body: {
            'contest_id': contestId,
            'work': work.toJson(),
            'images': imagesPayload,
            'file': filePayload,
          },
        );

        return Either.right(unit);
      },
    );
  }
}
