import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

//* Interface
abstract interface class EdgeRepository {
  Future<Either<Failure,Unit>> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  });

  Future<Either<Failure,Unit>> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  });
}

//* Implementation
class EdgeRepositoryImpl implements EdgeRepository {
  final SupabaseClient _supabase;

  EdgeRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Either<Failure,Unit>> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      final FunctionResponse res = await _supabase.functions.invoke('send-invite', body: {
        'email': email,
        'subject': 'You are invited to participate!',
        'html': '<h3>Hi, you are invited to join our contest.<br>'
            'Contest token: $contestToken<br>'
            'Invitation token: $participantToken</h3>',
      });
      if (res.status != 200) {
        return left(Failure(message: 'Failed to send invite'));
      }
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure,Unit>> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      final FunctionResponse res = await _supabase.functions.invoke('send-invite', body: {
        'email': email,
        'subject': 'You are invited to vote!',
        'html': '<h3>Hi, you are invited to join our contest.<br>'
            'Contest token: $contestToken<br>'
            'Invitation token: $jurorToken</h3>',
      });
      if (res.status != 200) {
        return left(Failure(message: 'Failed to send invite'));
      }
      return right(unit);
    } on PostgrestException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure());
    }
  }
}