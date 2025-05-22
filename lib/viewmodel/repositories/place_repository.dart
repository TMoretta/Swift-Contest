import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/services/place_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class PlaceRepository {
  Future<Either<Failure,Place>> createPlace({required Place place});

  Future<Either<Failure,Place>> updatePlace({required Place place});

  Future<Either<Failure,Unit>> deletePlaceById({required String id});

  Future<Either<Failure,Place>> getPlaceById({required String id});
}

//* Implementation
class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceService _placeService;

  PlaceRepositoryImpl({required PlaceService placeService}) : _placeService = placeService;

  @override
  Future<Either<Failure, Place>> createPlace({required Place place}) async{
    try {
      final result = await _placeService.createPlace(place: place);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePlaceById({required String id}) async{
    try {
      final result = await _placeService.deletePlaceById(id: id);
    return right(result);
    } on UnsafeException catch (e) {
    return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Place>> getPlaceById({required String id}) async{
    try {
      final result = await _placeService.getPlaceById(id: id);
    return right(result);
    } on UnsafeException catch (e) {
    return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Place>> updatePlace({required Place place,}) async{
    try {
      final result = await _placeService.updatePlace(place: place);
    return right(result);
    } on UnsafeException catch (e) {
    return left(Failure(message: e.message));
    }
  }
}