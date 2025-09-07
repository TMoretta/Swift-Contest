import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests permission to use the camera.
///
/// Essential for features like QR code scanning.
/// Returns the `PermissionStatus`.
Future<PermissionStatus> requestCameraPermission() async {
  // On web, permissions are handled by the browser.
  // The mobile_scanner package handles this internally for web.
  if (kIsWeb) {
    return PermissionStatus.granted;
  }
  // On non-mobile platforms, it's not needed.
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
/// Returns `true` if the permission is granted.
Future<bool> requestFineLocationPermission() async {
  // On web, browser geolocation API is used, which has its own permission prompt.
  if (kIsWeb) {
    return true; // Assume permission will be handled by the browser's prompt.
  }
  // On non-mobile platforms, it's not needed.
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
/// Returns `true` if the save operation can proceed.
Future<bool> requestStoragePermissionForDownloads() async {
  // On web, the browser handles downloads and permissions.
  if (kIsWeb) {
    return true;
  }

  if (!Platform.isAndroid) {
    // On iOS and other non-Android platforms, this permission isn't used for saving to 'Downloads'.
    return true;
  }

  // On Android, check the SDK version to decide if permission is needed.
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  if (deviceInfo.version.sdkInt >= 29) {
    // From Android 10 (API 29) onwards, no permission is needed to write to the Downloads folder.
    return true;
  }

  // For Android 9 (API 28) and below, storage permission is required.
  final status = await Permission.storage.request();
  return status.isGranted;
}
