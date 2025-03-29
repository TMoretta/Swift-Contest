import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/model/services/storage_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class StorageRepository {
  Future<Either<Failure,List<String>>> uploadImages({required List<XFile> images});
}

//* Implementation
class StorageRepositoryImpl implements StorageRepository {
  final StorageService _storageService;

  StorageRepositoryImpl({required StorageService storageService}) : _storageService = storageService;

  @override
  Future<Either<Failure,List<String>>> uploadImages({required List<XFile> images}) async {
    try {
      final res = await _storageService.uploadImages(images: images);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}