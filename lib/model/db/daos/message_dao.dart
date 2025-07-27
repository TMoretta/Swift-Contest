import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/utils/dao.dart';
import 'package:swift_contest/model/db/entities/message.dart';
import 'package:swift_contest/model/utils/handle_database_call.dart';
import 'package:swift_contest/utils/failures/failures.dart';


abstract interface class MessageDao implements Dao<Message> {
  Future<Either<Failure,List<Message>>> getByAccountId({required String accountId});

  Future<Either<Failure,Unit>> deleteByAccountId({required String accountId});
}

class MessageDaoImpl implements MessageDao {
  final SupabaseClient _supabase;

  MessageDaoImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<Either<Failure, Message>> create({required Message entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').insert(entity.toJson()).select().single();
      return Either.right(Message.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Message>> update({required Message entity}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').update(entity.toJson()).eq('id', entity.id!).select().single();
      return Either.right(Message.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('messages').delete().eq('id', id);
      return Either.right(unit);
    });
  }

  @override
  Future<Either<Failure, Message>> getById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').select().eq('id', id).limit(1).single();
      return Either.right(Message.fromJson(res));
    });
  }

  @override
  Future<Either<Failure, Message?>> getNullableById({required String id}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').select().eq('id', id).limit(1).maybeSingle();
      return Either.right(res != null ? Message.fromJson(res) : null);
    });
  }

  @override
  Future<Either<Failure, List<Message>>> getAll() async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').select();
      return Either.right(res.map((e) => Message.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, List<Message>>> getByAccountId({required String accountId}) async {
    return handleDatabaseCall(() async {
      final res = await _supabase.from('messages').select().eq('account_id', accountId);
      return Either.right(res.map((e) => Message.fromJson(e)).toList(growable: false));
    });
  }

  @override
  Future<Either<Failure, Unit>> deleteByAccountId({required String accountId}) async {
    return handleDatabaseCall(() async {
      await _supabase.from('messages').delete().eq('account_id', accountId);
      return Either.right(unit);
    });
  }
}
