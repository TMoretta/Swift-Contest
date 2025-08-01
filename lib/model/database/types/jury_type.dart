enum JuryType {
  appointed,
  simple,
}

extension JuryTypeX on JuryType {
  bool get isAppointed => this == JuryType.appointed;
  bool get isSimple => this == JuryType.simple;
}