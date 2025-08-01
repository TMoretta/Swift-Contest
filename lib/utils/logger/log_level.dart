enum LogLevel {
  debug, // Per informazioni di basso livello, utili solo per tracciare un flusso.
  info,  // Per eventi importanti ma normali (es. "Utente loggato").
  warning, // Per situazioni inaspettate che non sono errori critici.
  error, // Per errori, eccezioni e problemi che richiedono attenzione.
}