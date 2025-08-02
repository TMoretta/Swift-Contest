import 'package:flutter/material.dart';
import 'obscured_loader.dart';

class OverlayLoader {
  OverlayEntry? _entry;

  // Singleton pattern
  OverlayLoader._();

  static final OverlayLoader _instance = OverlayLoader._();

  factory OverlayLoader() => _instance;

  void show(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (_) => const Positioned.fill(
        child: ObscuredLoader(),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void hide() {
    _entry?.remove();
    _entry = null;
  }
}

extension OverlayLoaderX on BuildContext {
  void showLoader() => OverlayLoader().show(this);

  void hideLoader() => OverlayLoader().hide();
}
