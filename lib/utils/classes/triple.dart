import 'package:equatable/equatable.dart';

class Triple<V1, V2, V3> extends Equatable {
  final V1 value1;
  final V2 value2;
  final V3 value3;

  const Triple(this.value1, this.value2, this.value3);

  @override
  List<Object?> get props => [value1, value2, value3];
}
