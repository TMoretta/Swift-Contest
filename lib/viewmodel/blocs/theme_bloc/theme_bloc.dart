import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:swift_contest/model/enums/app_theme.dart';
import 'package:swift_contest/model/repositories/theme_repository.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

part 'theme_event.dart';

part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;

  ThemeBloc({
    required ThemeRepository themeRepository,
  })  : _themeRepository = themeRepository,
        super(ThemeState(status: BlocStatus.initial)) {
    on<LoadTheme>(_loadTheme);
    on<SaveTheme>(_saveTheme);

    add(LoadTheme());
  }

  FutureOr<void> _loadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final theme = await _themeRepository.loadTheme();
    emit(state.copyWith(status: BlocStatus.success, theme: theme));
  }

  FutureOr<void> _saveTheme(
    SaveTheme event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherSaveTheme = await _themeRepository.saveTheme(event.theme);
    eitherSaveTheme.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success, theme: event.theme)),
    );
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      return ThemeState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }
}
