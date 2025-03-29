import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/services/realtime/work_realtime_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class WorkRealtimeRepository {
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription);

  Either<Failure, RealtimeChannel> subscribeToWorksAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToWorksInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToWorksUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  });

  Either<Failure, RealtimeChannel> subscribeToWorksDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  });
}

class WorkRealtimeRepositoryImpl implements WorkRealtimeRepository {
  final WorkRealtimeService _workRealtimeService;

  WorkRealtimeRepositoryImpl({
    required WorkRealtimeService workRealtimeService,
  }) : _workRealtimeService = workRealtimeService;

  @override
  Either<Failure, Unit> unsubscribe(RealtimeChannel subscription) {
    try {
      _workRealtimeService.unsubscribe(subscription);
      return right(unit);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToWorksAllEvents({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _workRealtimeService.subscribeToWorksAllEvents(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToWorksInsertEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _workRealtimeService.subscribeToWorksInsertEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToWorksUpdateEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _workRealtimeService.subscribeToWorksUpdateEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Either<Failure, RealtimeChannel> subscribeToWorksDeleteEvent({
    required void Function(PostgresChangePayload payload) callback,
  }) {
    try {
      final channel = _workRealtimeService.subscribeToWorksDeleteEvent(callback: callback);
      return right(channel);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
