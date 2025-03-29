import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ContestRealtimeService {
  Unit unsubscribe(RealtimeChannel subscription);

  RealtimeChannel subscribeToContestsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToContestsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToContestsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToContestsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

//* Implementation
class ContestRealtimeServiceImpl implements ContestRealtimeService {
  final SupabaseClient _supabase;

  ContestRealtimeServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Unit unsubscribe(RealtimeChannel subscription) {
    try {
      _supabase.removeChannel(subscription);
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToContestsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('contests_all_events').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'contests',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToContestsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('contests_insert_event').onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'contests',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToContestsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('contests_update_event').onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'contests',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToContestsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('contests_delete_event').onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'contests',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
