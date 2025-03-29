import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Function(DateTime) onSelected;
  final String? Function(String?)? validator;

  const DatePickerField({
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
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        label: Text(label),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: Icon(Icons.calendar_today),
        suffixIcon: TextButton(
            onPressed: () async {
              final date = await _showDatePicker(context: context);
              if (date != null) {
                controller.text = DateFormat('dd/MM/yyyy').format(date);
                onSelected(date);
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

Future<DateTime?> _showDatePicker({required BuildContext context}) async {
  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2100),
  );
  return date;
}

// class DatePickerField extends StatefulWidget {
//   final TextEditingController textController;
//   final String label;
//   final String? Function(String?)? validator;
//   final Function(DateTime) onSelected;
//
//   const DatePickerField({
//     required this.label,
//     required this.textController,
//     this.validator,
//     required this.onSelected,
//     super.key,
//   });
//
//   @override
//   State<DatePickerField> createState() => _DatePickerFieldState();
// }
//
// class _DatePickerFieldState extends State<DatePickerField> {
//   Future<void> _showDatePicker(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//
//     if (pickedDate != null) {
//       setState(() {
//         widget.textController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
//       });
//       widget.onSelected(pickedDate);
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
//         helperText: '',
//         helperStyle: TextStyle(height: 1),
//         errorStyle: TextStyle(height: 1),
//         label: Text(widget.label),
//         floatingLabelBehavior: FloatingLabelBehavior.always,
//         prefixIcon: Icon(Icons.calendar_today),
//         suffixIcon: TextButton(
//             onPressed: () {
//               _showDatePicker(context);
//             },
//             child: Text('Select')
//         ),
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
