import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Richiede il permesso per utilizzare la fotocamera.
///
/// Essenziale per funzionalità come la scansione di QR code.
/// Restituisce `true` se il permesso è concesso.
Future<PermissionStatus> requestCameraPermission() async {
  // Su piattaforme non-mobile, non è necessario.
  if (!Platform.isAndroid && !Platform.isIOS) {
    return PermissionStatus.granted;
  }

  // final status = await Permission.camera.status;
  // if (status.isPermanentlyDenied) {
  //   openAppSettings();
  //   return false;
  // }
  final status = await Permission.camera.request();
  return status;
}

/// Richiede il permesso per accedere alla galleria fotografica.
///
/// Questa funzione è intelligente:
/// - Su Android 13+ richiede `Permission.photos`.
/// - Su Android < 13, `permission_handler` chiede automaticamente `Permission.storage`.
/// - Su iOS, chiede l'accesso alla libreria.
///
/// Usala prima di chiamare `image_picker`.
/// Restituisce `true` se il permesso è concesso.
Future<bool> requestPhotoLibraryPermission() async {
  // Su piattaforme non-mobile, non è necessario.
  if (!Platform.isAndroid && !Platform.isIOS) {
    return true;
  }

  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt <= 32) {
    final status = await Permission.storage.request();
    return status.isGranted;
  } else {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
}

/// Richiede il permesso per la localizzazione precisa (GPS).
///
/// Utile per funzionalità di geo-restrizione.
/// `locationWhenInUse` è la scelta migliore per la privacy quando l'app è in primo piano.
/// Restituisce `true` se il permesso è concesso.
Future<bool> requestFineLocationPermission() async {
  // Su piattaforme non-mobile, non è necessario.
  if (!Platform.isAndroid && !Platform.isIOS) {
    return true;
  }

  final status = await Permission.locationWhenInUse.request();
  return status.isGranted;
}

/// Richiede il permesso di scrittura per salvare file, gestendo la compatibilità.
///
/// Questa funzione è cruciale per la compatibilità con le versioni di Android:
/// - **Android < 10 (API < 29):** Richiede esplicitamente `Permission.storage`.
///   Questo è OBBLIGATORIO per salvare file in cartelle come 'Downloads'.
/// - **Android 10+ (API >= 29):** NON richiede permessi speciali per salvare
///   nella cartella 'Downloads' grazie allo Scoped Storage. La funzione
///   restituisce `true` direttamente.
/// - **iOS e altre piattaforme:** Restituisce `true` poiché la logica dei permessi
///   per il salvataggio è gestita diversamente.
///
/// Restituisce `true` se l'operazione di salvataggio può procedere.
Future<bool> requestStoragePermissionForDownloads() async {
  if (!Platform.isAndroid) {
    // Su iOS e altre piattaforme, non si usa questo permesso per salvare in 'Downloads'.
    return true;
  }

  // Controlla la versione dell'SDK per decidere se chiedere il permesso.
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt >= 29) {
    // Da Android 10 in poi, non serve il permesso per scrivere in Downloads.
    return true;
  }

  // Per Android 9 e inferiori, il permesso è necessario.
  final status = await Permission.storage.request();
  return status.isGranted;
}
