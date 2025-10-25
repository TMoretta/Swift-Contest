import 'package:flutter/material.dart';

class TimePickerFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final Function(TimeOfDay)? onSelected;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Widget? externalIcon;
  final Color? externalIconColor;
  final Widget? prefixIcon;
  final Color? prefixIconColor;
  final TimeOfDay? initialTime;

  const TimePickerFormField({
    required this.controller,
    this.focusNode,
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
    this.initialTime,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: controller,
      focusNode: focusNode,
      onTapOutside: (event) => focusNode?.unfocus(),
      autovalidateMode: autovalidateMode,
      validator: validator,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: TextButton(
          onPressed: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            final time = await _showTimePicker(context: context, initialTime: initialTime);
            if (time != null) {
              controller.text =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              if (onSelected != null) {
                onSelected!(time);
              }
            }
          },
          child: const Text('Select'),
        ),
        helperText: '',
        helperStyle: const TextStyle(height: 1),
        errorStyle: const TextStyle(height: 1),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceDim,
          ),
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
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

Future<TimeOfDay?> _showTimePicker({
  required BuildContext context,
  required TimeOfDay? initialTime,
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
