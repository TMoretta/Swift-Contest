import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_form.dart';
import 'package:swift_contest/model/services/voting_form_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class VotingFormRepository {
  Future<Either<Failure, VotingForm>> createVotingForm({required VotingForm votingForm});

  Future<Either<Failure, VotingForm>> updateVotingFormById({
    required String id,
    required VotingForm votingForm,
  });

  Future<Either<Failure, Unit>> deleteVotingFormById({required String id});

  Future<Either<Failure, VotingForm>> getVotingFormById({required String id});
}

//* Implementation
class VotingFormRepositoryImpl implements VotingFormRepository {
  final VotingFormService _votingFormService;

  VotingFormRepositoryImpl({required VotingFormService votingFormService})
      : _votingFormService = votingFormService;

  @override
  Future<Either<Failure, VotingForm>> createVotingForm({required VotingForm votingForm}) async {
    try {
      final result = await _votingFormService.createVotingForm(votingForm: votingForm);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVotingFormById({required String id}) async {
    try {
      final result = await _votingFormService.deleteVotingFormById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingForm>> getVotingFormById({required String id}) async {
    try {
      final result = await _votingFormService.getVotingFormById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingForm>> updateVotingFormById({
    required String id,
    required VotingForm votingForm,
  }) async {
    try {
      final result = await _votingFormService.updateVotingFormById(id: id, votingForm: votingForm);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
