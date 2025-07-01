//* No empty validator
String? noEmptyValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return '';
  }

  return null;
}

//* Email validator
String? emailValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return '';
  }

  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegex.hasMatch(val)) {
    return 'Enter a valid email';
  }

  return null;
}

//* Full name validator
String? fullNameValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return '';
  }

  if (val.length < 6) {
    return 'At least 5 characters long';
  }

  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(val)) {
    return 'Not valid symbol used';
  }

  return null;
}

//* Password validator
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }

  if (value.length < 8) {
    return 'Must contain at least 8 characters';
  }

  if (value.contains(RegExp(r'\s'))) {
    return 'Must not contain whitespace';
  }

  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Must contain at least one uppercase letter';
  }

  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Must contain at least one number';
  }

  if (!RegExp(r'[!@#$&*~%^()\[\]\-_=+{};:,.<>?/\\|]').hasMatch(value)) {
    return 'Must contain at least one special character';
  }

  return null;
}

//* Confirm password validator
String? confirmPasswordValidator(String? value, String? password) {
  if (value == null || value.isEmpty) {
    return '';
  }

  if (value != password) {
    return 'Passwords do not match';
  }

  return null;
}

//* OTP validator
String? otpValidator(String? value, int length) {
  final val = value?.trim();

  if (val == null || val.isEmpty || val.length != length) {
    return 'Enter a valid OTP';
  }

  return null;
}

//* Numbers validator
String? integerValidator(String? value) {
  final val = value?.trim();

  if(val == null || val.isEmpty) {
    return '';
  }

  if(!RegExp(r'^\d+$').hasMatch(val)) {
    return 'Invalid number, only integers allowed';
  }

  return null;
}
