import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Function(DateTime)? onSelected;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Icon? externalIcon;
  final Color? externalIconColor;
  final Icon? prefixIcon;
  final Color? prefixIconColor;

  const DatePickerFormField({
    required this.controller,
    this.label,
    this.onSelected,
    this.validator,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      style: TextStyle(
          fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: TextButton(
          onPressed: () async {
            final date = await _showDatePicker(context: context);
            if (date != null) {
              controller.text = DateFormat('dd/MM/yyyy').format(date);
              if (onSelected != null) {
                onSelected!(date);
              }
            }
          },
          child: Text('Select'),
        ),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
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
