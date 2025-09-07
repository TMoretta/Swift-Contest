import 'package:swift_contest/utils/functions/save_and_launch_file_stub.dart'
    if (dart.library.io) 'package:swift_contest/utils/functions/save_and_launch_file_mobile.dart'
    if (dart.library.html) 'package:swift_contest/utils/functions/save_and_launch_file_web.dart';
import 'package:swift_contest/utils/logger/logger.dart';

/// Saves a file from a list of bytes and then opens/downloads it.
///
/// This function is platform-aware and uses conditional imports to handle
/// web and mobile logic separately.
///
/// Returns a tuple: `(bool success, String? message)`.
/// The message provides context on the result (e.g., file path on mobile, or an error).
Future<(bool, String?)> saveAndLaunchFile(List<int> bytes, String fileName) async {
  try {
    return await saveAndLaunchFilePlatform(bytes, fileName);
  } catch (e, stackTrace) {
    Logger.error('Failed to save and launch file: $e', stackTrace);
    return (false, 'An error occurred: ${e.toString()}');
  }
}