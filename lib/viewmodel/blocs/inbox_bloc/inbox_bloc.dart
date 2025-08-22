import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/message.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'inbox_event.dart';

part 'inbox_state.dart';

class InboxBloc extends Bloc<InboxEvent, InboxState> {
  final AuthRepository _authRepository;

  InboxBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(InboxState(status: BlocStatus.initial)) {
    on<InboxGetStream>(_getStream);
    on<InboxMarkMessageAsRead>(_markMessageAsRead);
    on<InboxDeleteMessage>(_deleteMessage);
    on<InboxDeleteAllMessages>(_deleteAllMessages);
  }

  FutureOr<void> _getStream(
    InboxGetStream event,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherStream = await _authRepository.getMessagesStream();

    if (eitherStream.isLeft()) {
      emit(state.copyWith(
          status: BlocStatus.failure, message: eitherStream.getLeft().toNullable()!.message));
      return;
    }

    final Stream<List<Message>> stream = eitherStream.getRight().toNullable()!;

    await emit.forEach(
      stream,
      onData: (newMessages) {
        if(newMessages == state.messages ) {
          return state;
        }
        return state.copyWith(
            status: BlocStatus.success, isInitialized: true, messages: newMessages);
      },
      onError: (error, stackTrace) {
        return state.copyWith(status: BlocStatus.failure, message: 'An error occurred');
      },
    );
  }

  FutureOr<void> _markMessageAsRead(
    InboxMarkMessageAsRead event,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherMarkMessageAsRead =
        await _authRepository.markMessageAsRead(messageId: event.messageId);
    eitherMarkMessageAsRead.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        final updatedMessages = state.messages!.map((e) {
          if (e.id == event.messageId) {
            e = e.copyWith(isRead: true);
          }
          return e;
        }).toList(growable: false);
        emit(state.copyWith(status: BlocStatus.success, messages: updatedMessages));
      },
    );
  }

  FutureOr<void> _deleteMessage(
    InboxDeleteMessage event,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteMessage = await _authRepository.deleteMessage(messageId: event.messageId);
    eitherDeleteMessage.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) {
        // Create a new list, excluding the message to be deleted.
        final updatedMessages = List<Message>.from(state.messages!)
          ..removeWhere((msg) => msg.id == event.messageId);
        emit(state.copyWith(status: BlocStatus.success, messages: updatedMessages));
      },
    );
  }

  FutureOr<void> _deleteAllMessages(
    InboxDeleteAllMessages event,
    Emitter<InboxState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherDeleteAllMessages = await _authRepository.deleteAllAccountMessages();
    eitherDeleteAllMessages.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, messages: [])),
    );
  }
}
