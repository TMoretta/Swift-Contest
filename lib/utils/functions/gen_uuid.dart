import 'package:uuid/uuid.dart';

String genUuid() {
  return const Uuid().v4();
}