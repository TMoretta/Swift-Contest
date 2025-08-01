import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/utils/failures/failures.dart';

Failure edgeFunctionExceptionToFailure(FunctionException exception) {
  // Per gli sviluppatori: logga l'errore completo per il debug.
  // print('FunctionException: Status=${exception.status}, Details=${exception.details}');

  // 1. Priorità ai messaggi di errore personalizzati inviati dalla funzione.
  // Se la tua Edge Function restituisce un JSON come `{"error": "Messaggio specifico"}`,
  // questo blocco lo catturerà e lo mostrerà all'utente.
  if (exception.details is Map<String, dynamic>) {
    final detailsMap = exception.details as Map<String, dynamic>;
    if (detailsMap.containsKey('error')) {
      return CustomServerFailure(detailsMap['error'].toString());
    }
  }

  // 2. Se non c'è un errore personalizzato, mappa gli status code HTTP standard.
  switch (exception.status) {
    case 400: // Bad Request
      return const InvalidInputFailure('The request sent to the server function was malformed.');

    case 401: // Unauthorized
      return const AuthenticationFailure('You are not authorized to perform this action.');

    case 404: // Not Found
      return const NotFoundFailure('The server function could not be found.');

    case 429: // Too Many Requests
      return const TooManyRequestsFailure();

    case 500: // Internal Server Error
    case 502: // Bad Gateway
    case 503: // Service Unavailable
    case 504: // Gateway Timeout
      return const ServerFailure('The server function failed to execute or timed out.');

  // --- Caso di Default per tutti gli altri codici ---
    default:
    // Per qualsiasi codice non mappato, restituisci un errore generico e sicuro.
      return const ServerFailure('An unexpected error occurred with the server function.');
  }
}