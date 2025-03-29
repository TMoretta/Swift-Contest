import 'package:flutter/material.dart';

class CustomTextFormFieldOutlined extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  // final Function(String) onChanged;
  final FormFieldValidator<String>? validator;

  const CustomTextFormFieldOutlined({
    required this.controller,
    required this.label,
    // required this.onChanged,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.onSurface,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      // onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        label: Text(label),
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}

// class CustomTextFormFieldOutlined extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final FormFieldValidator<String>? validator;
//
//   const CustomTextFormFieldOutlined({
//     required this.label,
//     required this.controller,
//     this.validator,
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       cursorColor: Theme.of(context).colorScheme.onSurface,
//       style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//       controller: controller,
//       validator: validator,
//       autovalidateMode: AutovalidateMode.onUnfocus,
//       decoration: InputDecoration(
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16.0,
//           vertical: 14.0,
//         ),
//         label: Text(label),
//         helperText: '',
//         helperStyle: TextStyle(height: 1),
//         errorStyle: TextStyle(height: 1),
//         focusedBorder: OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Theme.of(context).colorScheme.errorContainer,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderSide: BorderSide(
//             color: Theme.of(context).colorScheme.error,
//           ),
//           borderRadius: BorderRadius.circular(8.0),
//         ),
//         filled: true,
//         fillColor: Theme.of(context).colorScheme.surface,
//       ),
//     );
//   }
// }

class CustomTextFormFieldUnderlined extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final FormFieldValidator<String>? validator;

  const CustomTextFormFieldUnderlined({
    required this.label,
    required this.onChanged,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.onSurface,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUnfocus,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        label: Text(label),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: false,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
