import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form.dart';
import 'package:swift_contest/model/data_models/voting_form/voting_form_field.dart';
import 'package:swift_contest/model/services/voting_form_service.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

abstract interface class VotingFormRepository {
  Future<Either<Failure, VotingForm>> getVotingFormById({required String id});

  Future<Either<Failure, VotingForm>> updateVotingFormById({
    required String id,
    required List<VotingFormField> fields,
  });
}

class VotingFormRepositoryImpl implements VotingFormRepository {
  final VotingFormService _votingFormService;

  VotingFormRepositoryImpl({required VotingFormService votingFormService})
      : _votingFormService = votingFormService;

  @override
  Future<Either<Failure, VotingForm>> getVotingFormById({required String id}) async {
    try {
      final res = await _votingFormService.getVotingFormById(id: id);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, VotingForm>> updateVotingFormById({
    required String id,
    required List<VotingFormField> fields,
  }) async {
    try {
      final res = await _votingFormService.updateVotingFormById(id: id, fields: fields);
      return right(res);
    } on CustomException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
