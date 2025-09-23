import 'package:intl/intl.dart';

extension StringToDateTimeX on String {
  DateTime toDateTime() {
    return DateFormat('dd/MM/yyyy HH:mm').parse(this);
  }
}
