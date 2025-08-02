// part of 'storage_image_fetcher_bloc.dart';
//
// @immutable
// final class StorageImageFetcherState extends Equatable {
//   final BlocStatus status;
//   final StorageImageFetcherEvent? sourceEvent;
//   final String? message;
//   final String? url;
//
//   const StorageImageFetcherState({
//     required this.status,
//     this.sourceEvent,
//     this.message,
//     this.url,
//   });
//
//   factory StorageImageFetcherState.fromJson(Map<String, dynamic> json) {
//     return StorageImageFetcherState(
//       status: BlocStatus.values.byName(json['status']),
//       url: json['url'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'status': status.name,
//       'url': url,
//     };
//   }
//
//   StorageImageFetcherState copyWith({
//     required BlocStatus status,
//     StorageImageFetcherEvent? sourceEvent,
//     String? message,
//     String? url,
//   }) {
//     return StorageImageFetcherState(
//       status: status,
//       sourceEvent: sourceEvent ?? this.sourceEvent,
//       message: message ?? this.message,
//       url: url ?? this.url,
//     );
//   }
//
//   @override
//   List<Object?> get props => [
//     status,
//     sourceEvent,
//     message,
//     url,
//   ];
// }