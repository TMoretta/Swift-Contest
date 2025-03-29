import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ParticipationRealtimeService {
  Unit unsubscribe(RealtimeChannel subscription);

  RealtimeChannel subscribeToParticipationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToParticipationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToParticipationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToParticipationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

//* Implementation
class ParticipationRealtimeServiceImpl implements ParticipationRealtimeService {
  final SupabaseClient _supabase;

  ParticipationRealtimeServiceImpl({required SupabaseClient supabaseClient})
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
  RealtimeChannel subscribeToParticipationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('participations_all_events').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'participations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToParticipationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('participations_insert_event').onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'participations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToParticipationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('participations_update_event').onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'participations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToParticipationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('participations_delete_event').onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'participations',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
