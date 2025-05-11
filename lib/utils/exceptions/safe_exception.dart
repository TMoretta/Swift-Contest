class SafeException implements Exception {
  final String message;

  SafeException({this.message = 'An error occurred. Please retry.'});

  @override
  String toString() {
    return message;
  }
}