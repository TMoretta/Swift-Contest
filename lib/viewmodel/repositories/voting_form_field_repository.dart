import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/services/voting_form_field_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingFormFieldRepository {
  Future<Either<Failure, VotingFormField>> createVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<Either<Failure, VotingFormField>> updateVotingFormField({
    required VotingFormField votingFormField,
  });

  Future<Either<Failure, Unit>> deleteVotingFormFieldById({required String id});

  Future<Either<Failure, VotingFormField>> getVotingFormFieldById({required String id});

  Future<Either<Failure, List<VotingFormField>>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  });
}

//* Implementation
class VotingFormFieldRepositoryImpl implements VotingFormFieldRepository {
  final VotingFormFieldService _votingFormFieldService;

  VotingFormFieldRepositoryImpl({required VotingFormFieldService votingFormFieldService})
      : _votingFormFieldService = votingFormFieldService;

  @override
  Future<Either<Failure, VotingFormField>> createVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final result =
          await _votingFormFieldService.createVotingFormField(votingFormField: votingFormField);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingFormFieldById({required String id}) async {
    try {
      final result = await _votingFormFieldService.deleteVotingFormFieldById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingFormField>> getVotingFormFieldById({required String id}) async {
    try {
      final result = await _votingFormFieldService.getVotingFormFieldById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<VotingFormField>>> getVotingFormFieldsByVotingFormId({
    required String votingFormId,
  }) async {
    try {
      final result = await _votingFormFieldService.getVotingFormFieldsByVotingFormId(
          votingFormId: votingFormId);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingFormField>> updateVotingFormField({
    required VotingFormField votingFormField,
  }) async {
    try {
      final result = await _votingFormFieldService.updateVotingFormField(votingFormField: votingFormField);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
