// import 'dart:async';
//
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';
// 
// import 'package:swift_contest/model/database/repositories/storage_repository.dart';
// import 'package:swift_contest/utils/logger/logger.dart';
// import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
//
// part 'storage_image_fetcher_event.dart';
// part 'storage_image_fetcher_state.dart';
//
// class StorageImageFetcherBloc extends HydratedBloc<StorageImageFetcherEvent, StorageImageFetcherState> {
//   final StorageRepository _storageRepository;
//
//   StorageImageFetcherBloc({required StorageRepository storageRepository})
//       : _storageRepository = storageRepository,
//         super(StorageImageFetcherState(status: BlocStatus.initial)) {
//     on<StorageImageFetcherFetchImageUrl>(_fetchImageUrl);
//   }
//
//   @override
//   StorageImageFetcherState? fromJson(Map<String, dynamic> json) {
//     try {
//       return StorageImageFetcherState.fromJson(json);
//     } catch (e) {
//       Logger.error(e);
//       return null;
//     }
//   }
//
//   @override
//   Map<String, dynamic>? toJson(StorageImageFetcherState state) {
//     try {
//       return state.toJson();
//     } catch (e) {
//       Logger.error(e);
//       return null;
//     }
//   }
//
//   FutureOr<void> _fetchImageUrl(
//     StorageImageFetcherFetchImageUrl event,
//     Emitter<StorageImageFetcherState> emit,
//   ) async {
//     emit(state.copyWith(status: BlocStatus.loading));
//     final eitherUrl = await _storageRepository.getDownloadUrl(
//       bucket: event.bucket,
//       path: event.path,
//     );
//     eitherUrl.fold(
//       (failure) =>
//           emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
//       (url) => emit(state.copyWith(status: BlocStatus.success, url: url)),
//     );
//   }
// }
