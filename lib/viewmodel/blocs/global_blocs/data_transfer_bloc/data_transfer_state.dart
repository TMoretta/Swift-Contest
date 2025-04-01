part of 'data_transfer_bloc.dart';

@immutable
sealed class DataTransferState extends Equatable {
  const DataTransferState();
}

final class DataTransferInitial extends DataTransferState {
  @override
  List<Object?> get props => [];
}

final class DataTransferSuccess extends DataTransferState {
  final Map<String, List<Map<String, dynamic>?>> data;

  const DataTransferSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

final class DataTransferFailure extends DataTransferState {
  final String message;

  const DataTransferFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// @immutable
// final class DataTransferState extends Equatable {
//   final BlocStatus status;
//   final String? message;
//   final List<Map<String, List<Map<String, dynamic>>>>? data;
//
//   const DataTransferState({required this.status, this.message, this.data});
//
//   DataTransferState copyWith({
//     required BlocStatus status,
//     String? message,
//     List<Map<String, List<Map<String, dynamic>>>>? data,
//   }) {
//     return DataTransferState(
//       status: status,
//       message: message,
//       data: data ?? this.data,
//     );
//   }
//
//   @override
//   List<Object?> get props => [status, message, data];
// }
