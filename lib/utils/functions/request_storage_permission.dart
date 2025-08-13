// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// Future<bool> requestStoragePermission() async {
//   AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
//   if (build.version.sdkInt >= 11) {
//     var request = await Permission.manageExternalStorage.request();
//     if (request.isGranted) {
//       return true;
//     } else {
//       return false;
//     }
//   } else {
//     if (await Permission.storage.isGranted) {
//       return true;
//     } else {
//       var request = await Permission.storage.request();
//       if (request.isGranted) {
//         return true;
//       } else {
//         return false;
//       }
//     }
//   }
// }