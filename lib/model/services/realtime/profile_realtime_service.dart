import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class ProfileRealtimeService {
  Unit unsubscribe(RealtimeChannel subscription);

  RealtimeChannel subscribeToProfilesAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToProfilesInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToProfilesUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  RealtimeChannel subscribeToProfilesDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

//* Implementation
class ProfileRealtimeServiceImpl implements ProfileRealtimeService {
  final SupabaseClient _supabase;

  ProfileRealtimeServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

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
  RealtimeChannel subscribeToProfilesAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('profiles_all_events').onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'profiles',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToProfilesInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('profiles_insert_event').onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'profiles',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToProfilesUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('profiles_update_event').onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'profiles',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  RealtimeChannel subscribeToProfilesDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      return _supabase.channel('profiles_delete_event').onPostgresChanges(
            event: PostgresChangeEvent.delete,
            schema: 'public',
            table: 'profiles',
            callback: callback,
          );
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}
