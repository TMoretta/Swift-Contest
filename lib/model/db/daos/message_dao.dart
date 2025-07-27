import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/daos/dao.dart';
import 'package:swift_contest/model/db/entities/message.dart';
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
    try {
      final res = await _supabase.from('messages').insert(entity.toJson()).select().single();
      return right(Message.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Message>> update({required Message entity}) async {
    try {
      final res = await _supabase.from('messages').update(entity.toJson()).eq('id', entity.id!).select().single();
      return right(Message.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteById({required String id}) async {
    try {
      await _supabase.from('messages').delete().eq('id', id);
      return right(unit);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Message>> getById({required String id}) async {
    try {
      final res = await _supabase.from('messages').select().eq('id', id).limit(1).single();
      return right(Message.fromJson(res));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Message?>> getNullableById({required String id}) async {
    try {
      final res = await _supabase.from('messages').select().eq('id', id).limit(1).maybeSingle();
      return right(res != null ? Message.fromJson(res) : null);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getAll() async {
    try {
      final res = await _supabase.from('messages').select();
      return right(res.map((e) => Message.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getByAccountId({required String accountId}) async {
    try {
      final res = await _supabase.from('messages').select().eq('account_id', accountId);
      return right(res.map((e) => Message.fromJson(e)).toList(growable: false));
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteByAccountId({required String accountId}) async {
    try {
      await _supabase.from('messages').delete().eq('account_id', accountId);
      return Either.right(unit);
    } on SocketException {
      return left(Failure( 'Network error'));
    } on PostgrestException catch (e) {
      return left(Failure( e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}
