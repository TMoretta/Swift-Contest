import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:swift_contest/model/database/bundles/organizer_contest_details_bundle.dart';
import 'package:swift_contest/model/database/entities/contest.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

part 'organizer_contest_edit_page_event.dart';
part 'organizer_contest_edit_page_state.dart';

class OrganizerContestEditPageBloc
    extends Bloc<OrganizerContestEditPageEvent, OrganizerContestEditPageState> {
  final OrganizerRepository _organizerRepository;
  final StorageRepository _storageRepository;

  OrganizerContestEditPageBloc({
    required OrganizerRepository organizerRepository,
    required StorageRepository storageRepository,
  })  : _organizerRepository = organizerRepository,
        _storageRepository = storageRepository,
        super(const OrganizerContestEditPageState(status: BlocStatus.initial)) {
    on<OrganizerContestEditPageFetch>(_fetch);
    on<OrganizerContestEditPageEditContest>(_edit);
  }

  FutureOr<void> _fetch(
    OrganizerContestEditPageFetch event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    late final OrganizerContestDetailsBundle contestDetailsBundle;
    final eitherContestDetails =
        await _organizerRepository.getContestDetails(contestId: event.contestId);
    eitherContestDetails.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => contestDetailsBundle = success,
    );
    if(eitherContestDetails.isLeft()) {
      return;
    }

    // --- Image Fetching Logic ---
    final dio = Dio();
    final List<XFile> images = [];
    final imagePaths = contestDetailsBundle.contestBundle.contest.imagesPaths;

    for (final imageStoragePath in imagePaths) {
      final eitherUrl = await _storageRepository.getSignedUrl(
        bucket: StorageBucket.contestsImages,
        path: imageStoragePath,
      );

      if (eitherUrl.isLeft()) {
        emit(state.copyWith(
            status: BlocStatus.failure, message: eitherUrl.getLeft().toNullable()!.message));
        return;
      }
      final url = eitherUrl.getRight().toNullable()!;

      try {
        if (kIsWeb) {
          // Web: Download image bytes into memory.
          final response = await dio.get<List<int>>(
            url,
            options: Options(responseType: ResponseType.bytes),
          );
          final bytes = Uint8List.fromList(response.data!);
          images.add(XFile.fromData(
            bytes,
            name: p.basename(imageStoragePath),
          ));
        } else {
          // Mobile: Download image to a temporary file.
          final tempDir = await getTemporaryDirectory();
          final localFilePath = '${tempDir.path}/${p.basename(imageStoragePath)}';
          await dio.download(url, localFilePath);
          images.add(XFile(localFilePath));
        }
      } catch (e) {
        Logger.error('Failed to download image $url: $e');
        emit(state.copyWith(
            status: BlocStatus.failure, message: 'Failed to retrieve contest images.'));
        return;
      }
    }

    // Emit the success state with the contest details and the downloaded images.
    emit(state.copyWith(
        status: BlocStatus.success, isInitialized: true, contestDetailsBundle: contestDetailsBundle, images: images));
  }

  FutureOr<void> _edit(
    OrganizerContestEditPageEditContest event,
    Emitter<OrganizerContestEditPageState> emit,
  ) async {
    emit(state.copyWith(status: BlocStatus.loading, sourceEvent: event));

    final eitherEditContest = await _organizerRepository.updateContest(
      contest: event.contest,
      place: event.place,
      images: (event.images.isNotEmpty) ? event.images : null,
    );
    eitherEditContest.fold(
      (failure) => emit(state.copyWith(status: BlocStatus.failure, message: failure.message)),
      (success) => emit(state.copyWith(status: BlocStatus.success)),
    );
  }
}
