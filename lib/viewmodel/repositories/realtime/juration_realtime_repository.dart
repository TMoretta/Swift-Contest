import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/services/realtime/juration_realtime_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class JurationRealtimeRepository {
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription);

  Either<Failure, RealtimeChannel> subscribeToJurationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToJurationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToJurationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToJurationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

class JurationRealtimeRepositoryImpl implements JurationRealtimeRepository {
  final JurationRealtimeService _jurationRealtimeService;

  JurationRealtimeRepositoryImpl({
    required JurationRealtimeService jurationRealtimeService,
  }) : _jurationRealtimeService = jurationRealtimeService;

  @override
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription) {
    try {
      _jurationRealtimeService.unsubscribe(subscription);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToJurationsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _jurationRealtimeService.subscribeToJurationsAllEvents(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToJurationsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _jurationRealtimeService.subscribeToJurationsInsertEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToJurationsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _jurationRealtimeService.subscribeToJurationsUpdateEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToJurationsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _jurationRealtimeService.subscribeToJurationsDeleteEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
