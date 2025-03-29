import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/services/realtime/participation_realtime_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class ParticipationRealtimeRepository {
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription);

  Either<Failure, RealtimeChannel> subscribeToParticipationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToParticipationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToParticipationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToParticipationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

class ParticipationRealtimeRepositoryImpl implements ParticipationRealtimeRepository {
  final ParticipationRealtimeService _participationRealtimeService;

  ParticipationRealtimeRepositoryImpl({
    required ParticipationRealtimeService participationRealtimeService,
  }) : _participationRealtimeService = participationRealtimeService;

  @override
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription) {
    try {
      _participationRealtimeService.unsubscribe(subscription);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToParticipationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _participationRealtimeService.subscribeToParticipationsAllEvents(
          callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToParticipationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _participationRealtimeService.subscribeToParticipationsInsertEvent(
          callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToParticipationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _participationRealtimeService.subscribeToParticipationsUpdateEvent(
          callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToParticipationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _participationRealtimeService.subscribeToParticipationsDeleteEvent(
          callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
