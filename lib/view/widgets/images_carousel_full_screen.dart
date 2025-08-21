import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';

/// A dialog widget that displays images in a full-screen PageView.
class ImagesCarouselFullScreen extends StatelessWidget {
  final StorageBucket bucket;
  final List<String> imagePaths;
  final int initialIndex;

  const ImagesCarouselFullScreen({
    required this.bucket,
    required this.imagePaths,
    required this.initialIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: imagePaths.length,
            itemBuilder: (context, index) => _KeepAliveImagePage(
              bucket: bucket,
              path: imagePaths[index],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white),
              ),
              onPressed: () => context.router.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A stateful widget that displays a single image and keeps it alive
/// within a PageView using [AutomaticKeepAliveClientMixin].
class _KeepAliveImagePage extends StatefulWidget {
  final StorageBucket bucket;
  final String path;

  const _KeepAliveImagePage({
    required this.bucket,
    required this.path,
  });

  @override
  State<_KeepAliveImagePage> createState() => _KeepAliveImagePageState();
}

class _KeepAliveImagePageState extends State<_KeepAliveImagePage>
    with AutomaticKeepAliveClientMixin {
  // By returning true, we tell Flutter to keep this widget's state alive.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for the mixin to work.
    return InteractiveViewer(
      child: StorageImage(bucket: widget.bucket, path: widget.path, fit: BoxFit.contain),
    );
  }
}
