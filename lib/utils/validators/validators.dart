String? noEmptyValidator(String? value) {
  final val = value?.trim();
  if (val == null || val.isEmpty) {
    return '';
  }
  return null;
}