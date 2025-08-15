import 'package:flutter/material.dart';

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
   TimeOfDay? initialTime,
}) async {
  final TimeOfDay? time = await showTimePicker(
    context: context,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
    initialTime: initialTime ?? TimeOfDay.now(),
  );
  return time;
}