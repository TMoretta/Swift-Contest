enum JurorStatus {
  joined,
  out,
}

extension JurorStatusX on JurorStatus {
  bool get isJoined => this == JurorStatus.joined;
  bool get isOut => this == JurorStatus.out;
}
