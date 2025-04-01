part of 'data_transfer_bloc.dart';

sealed class DataTransferEvent extends Equatable {
  const DataTransferEvent();
}

final class DataTransferSetData extends DataTransferEvent {
  final Map<String, List<Map<String, dynamic>?>> data;

  const DataTransferSetData({required this.data});

  @override
  List<Object?> get props => [data];
}

final class DataTransferGetData extends DataTransferEvent {
  @override
  List<Object?> get props => [];
}

final class DataTransferClearData extends DataTransferEvent {
  @override
  List<Object?> get props => [];
}
