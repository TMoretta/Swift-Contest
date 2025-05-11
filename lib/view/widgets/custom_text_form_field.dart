import 'package:flutter/material.dart';

//* CustomTextFormFieldOutlined
class CustomTextFormFieldOutlined extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Icon? externalIcon;
  final Color? externalIconColor;
  final Icon? prefixIcon;
  final Color? prefixIconColor;
  final Icon? suffixIcon;
  final Color? suffixIconColor;
  final Widget? prefix;
  final TextStyle? prefixStyle;
  final Widget? suffix;
  final TextStyle? suffixStyle;

  const CustomTextFormFieldOutlined({
    required this.controller,
    this.label,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.onSurface,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: suffixIcon,
        suffixIconColor: suffixIconColor,
        prefix: prefix,
        prefixStyle: prefixStyle,
        suffix: suffix,
        suffixStyle: suffixStyle,
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
      ),
    );
  }
}

//* CustomTextFormFieldUnderlined
class CustomTextFormFieldUnderlined extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? isFilled;
  final Color? fillColor;
  final Icon? externalIcon;
  final Color? externalIconColor;
  final Icon? prefixIcon;
  final Color? prefixIconColor;
  final Icon? suffixIcon;
  final Color? suffixIconColor;
  final Widget? prefix;
  final TextStyle? prefixStyle;
  final Widget? suffix;
  final TextStyle? suffixStyle;

  const CustomTextFormFieldUnderlined({
    required this.controller,
    this.label,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.isFilled,
    this.fillColor,
    this.externalIcon,
    this.externalIconColor,
    this.prefixIcon,
    this.prefixIconColor,
    this.suffixIcon,
    this.suffixIconColor,
    this.prefix,
    this.prefixStyle,
    this.suffix,
    this.suffixStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Theme.of(context).colorScheme.onSurface,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      controller: controller,
      validator: validator,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        label: Text(label ?? ''),
        filled: isFilled,
        fillColor: fillColor,
        icon: externalIcon,
        iconColor: externalIconColor,
        prefixIcon: prefixIcon,
        prefixIconColor: prefixIconColor,
        suffixIcon: suffixIcon,
        suffixIconColor: suffixIconColor,
        helperText: '',
        helperStyle: TextStyle(height: 1),
        errorStyle: TextStyle(height: 1),
        enabledBorder: UnderlineInputBorder(
          borderSide:
          BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}
