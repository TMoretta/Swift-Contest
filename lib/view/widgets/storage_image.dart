import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/view/widgets/loader.dart';

/// Un widget che recupera e visualizza un'immagine da Supabase Storage.
/// Gestisce correttamente il caching e l'aggiornamento dell'immagine
/// quando il percorso cambia, rendendolo ideale per l'uso in ListView.
class StorageImage extends StatefulWidget {
  final String bucket;
  final String path;
  final BoxFit? fit;
  final double? width;
  final double? height;

  const StorageImage({
    required this.bucket,
    required this.path,
    this.fit,
    this.width,
    this.height,
    super.key,
  });

  @override
  State<StorageImage> createState() => _StorageImageState();
}

class _StorageImageState extends State<StorageImage> {
  String? _imageUrl;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchImageUrl();
  }

  /// PUNTO CHIAVE: Questo metodo viene chiamato quando il widget viene ricostruito
  /// con nuovi parametri. Se il percorso dell'immagine è cambiato,
  /// dobbiamo recuperare il nuovo URL per evitare di mostrare l'immagine vecchia.
  @override
  void didUpdateWidget(covariant StorageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.path != oldWidget.path) {
      // Il percorso è cambiato, quindi ricarichiamo l'URL.
      _fetchImageUrl();
    }
  }

  Future<void> _fetchImageUrl() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final eitherUrl = await context
        .read<StorageRepository>()
        .getSignedUrl(bucket: widget.bucket, path: widget.path);

    if (mounted) {
      eitherUrl.fold(
            (failure) {
          Logger.error('Failed to fetch image URL for path "${widget.path}": ${failure.message}');
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        },
            (url) {
          setState(() {
            _imageUrl = url;
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: Loader());
    }

    if (_hasError || _imageUrl == null) {
      return const Icon(Icons.broken_image_outlined, color: Colors.grey);
    }

    return Image.network(
      _imageUrl!,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const Center(child: Loader());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image_outlined, color: Colors.grey);
      },
    );
  }
}
