import 'package:equatable/equatable.dart';

class Quadruple<V1, V2, V3, V4> extends Equatable {
  final V1 value1;
  final V2 value2;
  final V3 value3;
  final V4 value4;

  const Quadruple(
    this.value1,
    this.value2,
    this.value3,
    this.value4,
  );

  @override
  List<Object?> get props => [value1, value2, value3, value4];
}
