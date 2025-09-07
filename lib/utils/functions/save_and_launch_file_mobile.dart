import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:open_filex/open_filex.dart';
import 'package:swift_contest/utils/media_type.dart';

Future<(bool, String?)> saveAndLaunchFilePlatform(List<int> bytes, String fileName) async {
  // Mobile implementation: save to Downloads and open.
  final directory =
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);

  final baseName = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
  final extension = fileName.contains('.') ? fileName.substring(fileName.lastIndexOf('.')) : '';

  String safeFilename;
  int count = 0;
  do {
    safeFilename = (count == 0) ? '$baseName$extension' : '$baseName ($count)$extension';
    count++;
  } while (await File('$directory/$safeFilename').exists());

  final path = '$directory/$safeFilename';
  final file = File(path);
  await file.writeAsBytes(bytes);

  final result = await OpenFilex.open(path, type: MediaType.mapExtension(extension));
  if (result.type == ResultType.done) {
    return (true, 'File opened successfully.');
  } else {
    return (false, 'File saved to Downloads, but no app could open it.');
  }
}