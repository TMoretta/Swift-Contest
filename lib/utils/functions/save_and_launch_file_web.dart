import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<(bool, String?)> saveAndLaunchFilePlatform(List<int> bytes, String fileName) async {
  // Web implementation: trigger a browser download using the modern `package:web`.
  final blob = web.Blob([Uint8List.fromList(bytes).toJS].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = fileName;
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return (true, 'Download started in your browser.');
}