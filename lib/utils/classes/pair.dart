import 'package:equatable/equatable.dart';

class Pair<V1, V2> extends Equatable {
  final V1 value1;
  final V2 value2;

  const Pair(this.value1, this.value2);

  @override
  List<Object?> get props => [value1, value2];
}
