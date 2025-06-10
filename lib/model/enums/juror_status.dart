enum JurorStatus {
  joined,
  left,
}

extension JurorStatusX on JurorStatus {
  bool get isJoined => this == JurorStatus.joined;
  bool get isLeft => this == JurorStatus.left;
}
