import 'package:flutter/material.dart';

class TimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(TimeOfDay) onSelected;
  final String? Function(String?)? validator;

  const TimePickerField({
    required this.controller,
    required this.label,
    required this.onSelected,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        label: Text(label),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        prefixIcon: Icon(Icons.access_time_outlined),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: TextButton(
            onPressed: () async {
              final time = await _showTimePicker(context: context);
              if (time != null) {
                controller.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                onSelected(time);
              }
            },
            child: Text('Select')),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> _showTimePicker({required BuildContext context}) async {
  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  return time;
}

// class TimePickerField extends StatefulWidget {
//   final String label;
//   final TextEditingController textController;
//   final String? Function(String?)? validator;
//   final Function(TimeOfDay) onSelected;
//
//   const TimePickerField({
//     required this.label,
//     required this.textController,
//     this.validator,
//     required this.onSelected,
//     super.key,
//   });
//
//   @override
//   State<TimePickerField> createState() => _DatePickerFieldState();
// }
//
// class _DatePickerFieldState extends State<TimePickerField> {
//   Future<void> _showTimePicker(BuildContext context) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//
//     if (pickedTime != null) {
//       setState(() {
//         widget.textController.text =
//             '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
//       });
//       widget.onSelected(pickedTime);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       readOnly: true,
//       style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
//       controller: widget.textController,
//       validator: widget.validator,
//       textAlignVertical: TextAlignVertical.center,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//         label: Text(widget.label),
//         helperText: '',
//         helperStyle: TextStyle(height: 1),
//         errorStyle: TextStyle(height: 1),
//         prefixIcon: Icon(Icons.access_time_outlined),
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         suffixIcon: TextButton(
//             onPressed: () {
//               _showTimePicker(context);
//             },
//             child: Text('Select')),
//         border: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         filled: true,
//         fillColor: Theme.of(context).colorScheme.surface,
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.errorContainer),
//           borderRadius: BorderRadius.circular(8),
//         ),
//       ),
//     );
//   }
// }
