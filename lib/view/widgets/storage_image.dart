import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/storage_image_fetcher_bloc/storage_image_fetcher_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class StorageImage extends StatelessWidget {
  final String bucket;
  final String path;
  final BoxFit fit;

  const StorageImage({
    required this.bucket,
    required this.path,
    required this.fit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StorageImageFetcherBloc(
        storageRepository: context.read(),
      )..add(StorageImageFetcherFetchImageUrl(bucket: bucket, path: path)),
      child: BlocBuilder<StorageImageFetcherBloc, StorageImageFetcherState>(
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
            case BlocStatus.loading:
              return VoidWidget();
            case BlocStatus.failure:
              return Image.asset('assets/images/image_not_found.jpg', fit: fit);
            case BlocStatus.success:
              if (state.url == null) {
                return Image.asset('assets/images/image_not_found.jpg', fit: fit);
              }
              return Image.network(
                state.url!,
                fit: fit,
                frameBuilder:
                    (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return const Loader();
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/image_not_found.jpg',
                    fit: BoxFit.cover,
                  );
                },
              );
          }
        },
      ),
    );
  }
}
