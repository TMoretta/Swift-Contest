//* No empty validator
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

String? noEmptyValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }

  return null;
}

//* Email validator
String? emailValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }

  // RFC standard max length for an email address.
  if (val.length > 254) {
    return 'Email cannot exceed 254 characters';
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
  final val = value?.trim(); // Remove leading/trailing whitespace.

  if (val == null || val.isEmpty) {
    return 'Required';
  }

  // A more reasonable minimum length for a full name.
  if (val.length < 3) {
    return 'Must be at least 3 characters long';
  }

  if (val.length > 70) {
    return 'Cannot exceed 70 characters';
  }

  // A simple check to encourage entering both first and last names.
  if (!val.contains(' ')) {
    return 'Please include a last name';
  }

  // Check for multiple consecutive spaces.
  if (val.contains('  ')) {
    return 'Remove extra spaces between names';
  }

  // This more inclusive regex allows:
  // - Unicode letters (for names with accents like "José" or "Müller").
  // - Apostrophes (for names like "O'Connor").
  // - Hyphens (for names like "Marie-Claire").
  if (!RegExp(r"^[a-zA-Zà-üÀ-Ü'\- ]+$").hasMatch(val)) {
    return 'Name contains invalid characters';
  }

  return null;
}

//* Password validator
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Required';
  }

  if (value.length < 8) {
    return 'Must contain at least 8 characters';
  }

  // A sensible maximum length for passwords to prevent long-password DoS attacks.
  if (value.length > 128) {
    return 'Cannot exceed 128 characters';
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
    return 'Required';
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

/// Validator for titles (e.g., contest name, work name).
String? titleValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }
  if (val.length < 3) {
    return 'Must be at least 3 characters long';
  }
  if (val.length > 50) {
    return 'Cannot exceed 50 characters';
  }
  return null;
}

/// Validator for descriptions.
String? descriptionValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }
  if (val.length < 10) {
    return 'Must be at least 10 characters long';
  }
  if (val.length > 1000) {
    return 'Cannot exceed 1000 characters';
  }
  return null;
}

/// Validator for voting form questions.
String? questionValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }
  if (val.length < 5) {
    return 'Must be at least 5 characters long';
  }
  if (val.length > 255) {
    return 'Cannot exceed 255 characters';
  }
  return null;
}


String? atLeastOneImageValidator(List<XFile>? images) {
  if (images?.isEmpty ?? true) {
    return 'Select at least one image';
  }
  return null;
}

//* Numbers validator
String? integerValidator(String? value) {
  final val = value?.trim();

  if (val == null || val.isEmpty) {
    return 'Required';
  }

  // Prevents numbers that would overflow a standard 32-bit integer.
  if (val.length > 9) {
    return 'Number is too large';
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
    return 'Required';
  }

  try {
    final DateTime worksSubmissionStart = DateFormat('dd/MM/yyyy HH:mm').parse(value);
    if (worksSubmissionStart.isAfter(contestDate)) {
      return "Can't be after contest date";
    }
    if (worksSubmissionStart.isAtSameMomentAs(contestDate)) {
      return "Can't be equal to contest date";
    }
    if (worksSubmissionEnd == null) {
      return null;
    }
    if (worksSubmissionStart.isAfter(worksSubmissionEnd)) {
      return "Can't be after the end date";
    }
    if (worksSubmissionStart.isAtSameMomentAs(worksSubmissionEnd)) {
      return "Can't be the same as the end date";
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
    return 'Required';
  }

  try {
    final DateTime worksSubmissionEnd = DateFormat('dd/MM/yyyy HH:mm').parse(value);
    if (worksSubmissionEnd.isAfter(contestDate)) {
      return "Can't be after contest date";
    }
    if (worksSubmissionEnd.isAtSameMomentAs(contestDate)) {
      return "Can't be equal to contest date";
    }
    if (worksSubmissionStart == null) {
      return null;
    }
    if (worksSubmissionEnd.isBefore(worksSubmissionStart)) {
      return "Can't be before the start date";
    }
    if (worksSubmissionEnd.isAtSameMomentAs(worksSubmissionStart)) {
      return "Can't be the same as the start date";
    }
  } catch (e) {
    return 'Invalid date format';
  }
  return null;
}
