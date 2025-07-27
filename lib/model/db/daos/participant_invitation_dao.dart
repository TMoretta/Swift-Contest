import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/participant_invitation.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class ParticipantInvitationDao implements Dao<ParticipantInvitation> {}

class ParticipantInvitationDaoImpl implements ParticipantInvitationDao {
  final SupabaseClient _supabase;

  ParticipantInvitationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, ParticipantInvitation>> create({required ParticipantInvitation entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participant_invitations').insert(entity.toJson()).select().single();
      return Either.right(ParticipantInvitation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, ParticipantInvitation>> update({required ParticipantInvitation entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participant_invitations').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(ParticipantInvitation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('participant_invitations').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, ParticipantInvitation>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participant_invitations').select().eq('id', id).limit(1).single();
      return Either.right(ParticipantInvitation.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, ParticipantInvitation?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participant_invitations').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? ParticipantInvitation.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<ParticipantInvitation>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('participant_invitations').select();
      return Either.right(res.map((e) => ParticipantInvitation.fromJson(e)).toList(growable: false));
    });
  }
}
