import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';

Future<(bool, String?)> saveAndLaunchFilePlatform(List<int> bytes, String fileName) async {
  // Mobile implementation: save to Downloads and open.
  final directory =
      await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);

  final baseName = p.basenameWithoutExtension(fileName);
  final extension = p.extension(fileName);

  String safeFilename;
  int count = 0;
  do {
    safeFilename = (count == 0) ? '$baseName$extension' : '$baseName ($count)$extension';
    count++;
  } while (await File('$directory/$safeFilename').exists());

  final path = '$directory/$safeFilename';
  final file = File(path);
  await file.writeAsBytes(bytes);

  await OpenFilex.open(path);
  return (true, 'File saved to Downloads.');
}
