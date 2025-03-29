import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:uuid/uuid.dart';

//* Interface
abstract interface class StorageService {
  Future<List<String>> uploadImages({required List<XFile> images});
}

//* Implementation
class StorageServiceImpl implements StorageService {
  final SupabaseClient _supabase;

  StorageServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<List<String>> uploadImages({required List<XFile> images}) async {
    const bucketName = 'contests_images';
    final uuid = Uuid();

    List<String> uploadedPaths = [];
    List<String> imagesUrls = [];

    try {
      for (var image in images) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final fileName = uuid.v4();
          await _supabase.storage.from(bucketName).uploadBinary(fileName, bytes,
              fileOptions: FileOptions(contentType: image.mimeType));
          uploadedPaths.add(fileName);
          final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        } else {
          final imageToUpload = File(image.path);
          final fileName = uuid.v4();
          await _supabase.storage
              .from(bucketName)
              .upload(fileName, imageToUpload, fileOptions: FileOptions(contentType: image.mimeType));
          uploadedPaths.add(fileName);
          final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(fileName);
          imagesUrls.add(publicUrl);
        }
      }
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        await _supabase.storage.from(bucketName).remove(uploadedPaths);
      }
      throw CustomException(message: e.toString());
    }
    return imagesUrls;
  }
}