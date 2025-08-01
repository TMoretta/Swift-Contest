import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/database/entities/juror_invitation.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class JurorInvitationDao implements Dao<JurorInvitation> {}

class JurorInvitationDaoImpl implements JurorInvitationDao {
  final SupabaseClient _supabase;

  JurorInvitationDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, JurorInvitation>> create({required JurorInvitation entity}) async =>
      handleDatabaseCall(() async {
        final res = await _supabase.from('juror_invitations').insert(entity.toJson()).select().single();
        return Either.right(JurorInvitation.fromJson(res));
      });

  @override
  Future<Either<Failure, JurorInvitation>> update({required JurorInvitation entity}) async =>
      handleDatabaseCall(() async {
        final res = await _supabase.from('juror_invitations').update(entity.toJson()).eq('id', entity.id!).select().single();
        return Either.right(JurorInvitation.fromJson(res));
      });

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async =>
      handleDatabaseCall(() async {
        await _supabase.from('juror_invitations').delete().eq('id', id);
        return Either.right(unit);
      });

  @override
  Future<Either<Failure, JurorInvitation>> getById({required String id}) async =>
      handleDatabaseCall(() async {
        final res = await _supabase.from('juror_invitations').select().eq('id', id).limit(1).single();
        return Either.right(JurorInvitation.fromJson(res));
      });

  @override
  Future<Either<Failure, JurorInvitation?>> getNullableById({required String id}) async =>
      handleDatabaseCall(() async {
        final res = await _supabase.from('juror_invitations').select().eq('id', id).limit(1).maybeSingle();
        return Either.right(res != null ? JurorInvitation.fromJson(res) : null);
      });

  @override
  Future<Either<Failure, List<JurorInvitation>>> getAll() async =>
      handleDatabaseCall(() async {
        final res = await _supabase.from('juror_invitations').select();
        return Either.right(res.map((e) => JurorInvitation.fromJson(e)).toList(growable: false));
      });
}
