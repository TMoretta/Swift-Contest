import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/exceptions/custom_exception.dart';

//* Interface
abstract interface class EdgeService {
  Future<Unit> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  });

  Future<Unit> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  });
}

//* Implementation
class EdgeServiceImpl implements EdgeService {
  final SupabaseClient _supabase;

  EdgeServiceImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;

  @override
  Future<Unit> sendParticipantInvite({
    required String participantToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      await _supabase.functions.invoke('send-invite', body: {
        'email': email,
        'subject': 'You are invited to participate!',
        'html': '<p>Hi, you are invited to join our contest.</br>'
            'Contest token: $contestToken</br>'
            'Invitation token: $participantToken</p>',
      });
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }

  @override
  Future<Unit> sendJurorInvite({
    required String jurorToken,
    required String contestToken,
    required String email,
  }) async {
    try {
      await _supabase.functions.invoke('send-invite', body: {
        'email': email,
        'subject': 'You are invited to vote!',
        'html': '<p>Hi, you are invited to join our contest.</br>'
            'Contest token: $contestToken</br>'
            'Invitation token: $jurorToken</p>',
      });
      return unit;
    } catch (e) {
      throw CustomException(message: e.toString());
    }
  }
}