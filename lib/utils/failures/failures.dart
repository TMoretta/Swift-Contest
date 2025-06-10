class Failure {
  final String message;

  Failure({this.message = 'An error occurred. Check connection or retry'});

  @override
  String toString() {
    return message;
  }
}
