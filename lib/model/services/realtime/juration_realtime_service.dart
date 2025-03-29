import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class JurationRealtimeService {
  Unit unsubscribe(RealtimeChannel subscription);

  RealtimeChannel subscribeToJurationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToJurationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToJurationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToJurationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

//* Implementation
class JurationRealtimeServiceImpl implements JurationRealtimeService {
  final SupabaseClient _supabase;

  JurationRealtimeServiceImpl({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

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
  RealtimeChannel subscribeToJurationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('jurations_all_events').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'jurations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToJurationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('jurations_insert_event').onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'jurations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToJurationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('jurations_update_event').onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'jurations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToJurationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('jurations_delete_event').onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'jurations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
