import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class WorkRealtimeService {
  Unit unsubscribe(RealtimeChannel subscription);

  RealtimeChannel subscribeToWorksAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToWorksInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToWorksUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToWorksDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

//* Implementation
class WorkRealtimeServiceImpl implements WorkRealtimeService {
  final SupabaseClient _supabase;

  WorkRealtimeServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

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
  RealtimeChannel subscribeToWorksAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('works_all_events').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'works',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToWorksInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('works_insert_event').onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'works',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToWorksUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('works_update_event').onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'works',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToWorksDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('works_delete_event').onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'works',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
