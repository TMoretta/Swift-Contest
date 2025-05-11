//* Interface
import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/services/utils_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class UtilsRepository {
  Future<Either<Failure, String>> genUniqueToken({
    required String tableName,
    required String columnName,
    required int length,
  });
}

class UtilsRepositoryImpl implements UtilsRepository {
  final UtilsService _utilsService;

  UtilsRepositoryImpl({required UtilsService utilsService}) : _utilsService = utilsService;

  @override
  Future<Either<Failure, String>> genUniqueToken({
    required String tableName,
    required String columnName,
    required int length,
  }) async {
    try {
      final result = await _utilsService.genUniqueToken(
          tableName: tableName, columnName: columnName, length: length);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
