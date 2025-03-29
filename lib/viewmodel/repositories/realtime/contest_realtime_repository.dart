import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/services/realtime/contest_realtime_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class ContestRealtimeRepository {
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription);

  Either<Failure, RealtimeChannel> subscribeToContestsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToContestsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToContestsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToContestsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

class ContestRealtimeRepositoryImpl implements ContestRealtimeRepository {
  final ContestRealtimeService _contestRealtimeService;

  ContestRealtimeRepositoryImpl({
    required ContestRealtimeService contestRealtimeService,
  }) : _contestRealtimeService = contestRealtimeService;

  @override
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription) {
    try {
      _contestRealtimeService.unsubscribe(subscription);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToContestsAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _contestRealtimeService.subscribeToContestsAllEvents(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToContestsInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _contestRealtimeService.subscribeToContestsInsertEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToContestsUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _contestRealtimeService.subscribeToContestsUpdateEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToContestsDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _contestRealtimeService.subscribeToContestsDeleteEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
