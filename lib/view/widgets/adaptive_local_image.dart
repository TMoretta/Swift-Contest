import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class AdaptiveLocalImage extends StatelessWidget {
  final XFile image;
  final BoxFit fit;
  const AdaptiveLocalImage({required this.image, required this.fit, super.key,});

  @override
  Widget build(BuildContext context) {
    return (kIsWeb)
        ? Image.network(
      image.path,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const Loader();
      },
    )
        : Image.file(
      File(image.path),
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const Loader();
      },
    );
  }
}
