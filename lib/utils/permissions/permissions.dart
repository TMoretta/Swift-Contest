import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
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

/// Requests permission to access the photo library.
///
/// This function is platform-aware:
/// - On Web, no permission is needed as the browser handles file picking.
/// - On Android 13+ (API 33+), it requests `Permission.photos`.
/// - On older Android versions, it requests `Permission.storage`.
/// - On iOS, it requests `Permission.photos`.
///
/// Use this before calling `image_picker`.
/// Returns `true` if the permission is granted.
Future<bool> requestPhotoLibraryPermission() async {
  // On web, permissions for picking files are handled by the browser.
  if (kIsWeb) {
    return true;
  }

  // On mobile platforms, request the appropriate permission.
  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final Permission permission;
    // Android 13 (API 33) and higher use granular media permissions.
    if (deviceInfo.version.sdkInt >= 33) {
      permission = Permission.photos;
    } else {
      // Older versions use storage permission.
      permission = Permission.storage;
    }
    final status = await permission.request();
    return status.isGranted;
  } else if (Platform.isIOS) {
    // On iOS, always request photos permission.
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  // For other platforms (desktop), assume no permission is needed.
  return true;
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
