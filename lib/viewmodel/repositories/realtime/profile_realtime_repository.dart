import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/services/realtime/profile_realtime_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class ProfileRealtimeRepository {
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription);

  Either<Failure, RealtimeChannel> subscribeToProfilesAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToProfilesInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToProfilesUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToProfilesDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

class ProfileRealtimeRepositoryImpl implements ProfileRealtimeRepository {
  final ProfileRealtimeService _profileRealtimeService;

  ProfileRealtimeRepositoryImpl({
    required ProfileRealtimeService profileRealtimeService,
  }) : _profileRealtimeService = profileRealtimeService;

  @override
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription) {
    try {
      _profileRealtimeService.unsubscribe(subscription);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToProfilesAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _profileRealtimeService.subscribeToProfilesAllEvents(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToProfilesInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _profileRealtimeService.subscribeToProfilesInsertEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToProfilesUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _profileRealtimeService.subscribeToProfilesUpdateEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToProfilesDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _profileRealtimeService.subscribeToProfilesDeleteEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
