import 'package:flutter/material.dart';

class TimePickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Function(TimeOfDay)? onSelected;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Icon? externalIcon;
  final Color? externalIconColor;
  final Icon? prefixIcon;
  final Color? prefixIconColor;

  const TimePickerFormField({
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
      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
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
              final time = await _showTimePicker(context: context);
              if (time != null) {
                controller.text =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                if(onSelected!=null) {
                  onSelected!(time);
                }

              }
            },
            child: Text('Select'),),
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

Future<TimeOfDay?> _showTimePicker({required BuildContext context}) async {
  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  return time;
}
