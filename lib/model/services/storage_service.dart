import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:uuid/uuid.dart';

class StorageBucket {
  StorageBucket._();

  static const String contestsImages = 'contests-images';
  static const String worksImages = 'works-images';
}

//* Interface
abstract interface class StorageService {
  Future<List<String>> uploadImages({required String bucket, required List<XFile> images});
}

//* Implementation
class StorageServiceImpl implements StorageService {
  final SupabaseClient _supabase;

  StorageServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<List<String>> uploadImages({required String bucket, required List<XFile> images}) async {
    final uuid = Uuid();

    List<String> uploadedPaths = [];
    List<String> imagesUrls = [];

    try {
      for (var image in images) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final fileName = uuid.v4();
          await _supabase.storage
              .from(bucket)
              .uploadBinary(fileName, bytes, fileOptions: FileOptions(contentType: image.mimeType));
          uploadedPaths.add(fileName);
          final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        } else {
          final imageToUpload = File(image.path);
          final fileName = uuid.v4();
          await _supabase.storage.from(bucket).upload(fileName, imageToUpload,
              fileOptions: FileOptions(contentType: image.mimeType));
          uploadedPaths.add(fileName);
          final publicUrl = _supabase.storage.from(bucket).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        }
      }
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        await _supabase.storage.from(bucket).remove(uploadedPaths);
      }
      throw UnsafeException(message: e.toString());
    }
    return imagesUrls;
  }
}
