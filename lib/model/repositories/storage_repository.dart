import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';
import 'package:swift_contest/utils/functions/gen_uuid.dart';

class StorageBucket {
  StorageBucket._();

  static const String contestsImages = 'contests-images';
  static const String worksImages = 'works-images';
  static const String worksFiles = 'works-files';
}

//* Interface
abstract interface class StorageRepository {
  Future<Either<Failure, List<String>>> uploadImages({
    required String bucket,
    required List<XFile> images,
  });

  Future<Either<Failure, String>> uploadFile({
    required String bucket,
    required File file,
  });
}

//* Implementation
class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient _supabase;

  StorageRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure, List<String>>> uploadImages({
    required String bucket,
    required List<XFile> images,
  }) async {
    List<String> imagesUrls = [];

    try {
      for (var image in images) {
        final fileName = genUuid();
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          await _supabase.storage
              .from(bucket)
              .uploadBinary(fileName, bytes, fileOptions: FileOptions(contentType: image.mimeType));
          final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        } else {
          final imageToUpload = File(image.path);
          await _supabase.storage.from(bucket).upload(fileName, imageToUpload,
              fileOptions: FileOptions(contentType: image.mimeType));
          final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        }
      }
    } catch (e) {
      return left(Failure());
    }
    return right(imagesUrls);
  }

  @override
  Future<Either<Failure, String>> uploadFile({
    required String bucket,
    required File file,
  }) async {
    try {
      final String fileName = '${genUuid()}/${basename(file.path)}';
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        await _supabase.storage.from(bucket).uploadBinary(fileName, bytes);
        final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
        return right(publicUrl);
      } else {
        await _supabase.storage.from(bucket).upload(fileName, file);
        final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
        return right(publicUrl);
      }
    } catch (e) {
      return left(Failure());
    }
  }
}
