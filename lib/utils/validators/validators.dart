//* No empty validator
import 'package:intl/intl.dart';

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

  if (val == null || val.isEmpty) {
    return '';
  }

  if (!RegExp(r'^\d+$').hasMatch(val)) {
    return 'Invalid number, only integers allowed';
  }

  return null;
}

//* Works submission start validator
String? worksSubmissionStartValidator(
  String? value,
  DateTime contestDate,
  DateTime? worksSubmissionEnd,
) {
  if (value == null || value.isEmpty) {
    return '';
  }

  try {
    final DateTime worksSubmissionStart = DateFormat('dd/MM/yyyy HH:mm').parse(value);
    if (worksSubmissionStart.isAfter(contestDate)) {
      return 'Can\'t be after contest date';
    }
    if (worksSubmissionStart == contestDate) {
      return 'Can\'t be equal to contest date';
    }
    if (worksSubmissionEnd == null) {
      return null;
    }
    if (worksSubmissionStart.isAfter(worksSubmissionEnd)) {
      return 'Can\'t be after the date of the end';
    }
    if (worksSubmissionStart == worksSubmissionEnd) {
      return 'Can\'t be the same date of the ending';
    }
  } catch (e) {
    return 'Invalid date format';
  }
  return null;
}

//* Works submission start validator
String? worksSubmissionEndValidator(
  String? value,
  DateTime contestDate,
  DateTime? worksSubmissionStart,
) {
  if (value == null || value.isEmpty) {
    return '';
  }

  try {
    final DateTime worksSubmissionEnd = DateFormat('dd/MM/yyyy HH:mm').parse(value);
    if (worksSubmissionEnd.isAfter(contestDate)) {
      return 'Can\'t be after contest date';
    }
    if (worksSubmissionEnd == contestDate) {
      return 'Can\'t be equal to contest date';
    }
    if (worksSubmissionStart == null) {
      return null;
    }
    if (worksSubmissionEnd.isBefore(worksSubmissionStart)) {
      return 'Can\'t be before the date of begin';
    }
    if (worksSubmissionEnd == worksSubmissionStart) {
      return 'Can\'t be the same date of the starting';
    }
  } catch (e) {
    return 'Invalid date format';
  }
  return null;
}
