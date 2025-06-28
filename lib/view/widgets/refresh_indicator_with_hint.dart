import 'package:flutter/material.dart';
import 'package:swift_contest/view/widgets/pull_to_refresh_hint.dart';

class RefreshIndicatorWithHint extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const RefreshIndicatorWithHint({required this.onRefresh, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 4,
          child: PullToRefreshHint(),
        ),
        RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: ListView(),
        ),
      ],
    );
  }
}
