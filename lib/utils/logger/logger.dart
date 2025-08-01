import 'package:flutter/foundation.dart';

// Codici di escape ANSI per i colori nella console.
// Potrebbero non funzionare su tutte le console (es. la console di debug di Windows),
// ma funzionano benissimo sulla console di Android Studio/VS Code e sui terminali macOS/Linux.
const _ansiReset = '\x1B[0m';
const _ansiRed = '\x1B[31m';
const _ansiGreen = '\x1B[32m';
const _ansiYellow = '\x1B[33m';
const _ansiBlue = '\x1B[34m';

enum LogLevel {
  debug, // Per informazioni di basso livello, utili solo per tracciare un flusso.
  info,  // Per eventi importanti ma normali (es. "Utente loggato").
  warning, // Per situazioni inaspettate che non sono errori critici.
  error, // Per errori, eccezioni e problemi che richiedono attenzione.
}

/// Un logger completo con livelli di severità, colori e icone.
/// Le chiamate vengono rimosse automaticamente nelle build di release.
class Logger {
  Logger._(); // Costruttore privato per impedire l'istanziazione.

  /// Il livello minimo di log da visualizzare.
  /// Utile per ridurre il rumore in console durante lo sviluppo.
  /// Esempio: Logger.level = LogLevel.warning; mostrerà solo warning ed errori.
  static LogLevel level = LogLevel.debug;

  /// Logga un messaggio con livello DEBUG.
  /// Utile per tracciare il valore di variabili o passaggi specifici.
  static void debug(Object? message) {
    _log(LogLevel.debug, '🐛', _ansiBlue, message);
  }

  /// Logga un messaggio con livello INFO.
  /// Per eventi di alto livello nel flusso dell'applicazione.
  static void info(Object? message) {
    _log(LogLevel.info, 'ℹ️', _ansiGreen, message);
  }

  /// Logga un messaggio con livello WARNING.
  /// Per problemi potenziali che non bloccano l'app.
  static void warning(Object? message) {
    _log(LogLevel.warning, '⚠️', _ansiYellow, message);
  }

  /// Logga un messaggio con livello ERROR.
  /// Per eccezioni e fallimenti critici.
  static void error(Object? error, [StackTrace? stackTrace]) {
    _log(LogLevel.error, '🚨', _ansiRed, error);
    if (stackTrace != null) {
      // Stampa lo stack trace separatamente per una migliore leggibilità.
      _log(LogLevel.error, '🚨', _ansiRed, stackTrace);
    }
  }

  static void _log(LogLevel logLevel, String icon, String color, Object? message) {
    // Questo è il cuore del meccanismo di "tree-shaking".
    // Il compilatore rimuoverà questo intero blocco in modalità release.
    if (kDebugMode) {
      // Controlla se la severità del messaggio è sufficientemente alta per essere loggata.
      if (logLevel.index >= level.index) {
        debugPrint('$color$icon [${logLevel.name.toUpperCase()}]: $message$_ansiReset');
      }
    }
  }
}