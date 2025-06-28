import 'package:flutter/material.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';

class PullToRefreshHint extends StatefulWidget {
  const PullToRefreshHint({super.key});

  @override
  State<PullToRefreshHint> createState() => _PullToRefreshHintState();
}

class _PullToRefreshHintState extends State<PullToRefreshHint> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _offsetAnim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnim,
      child: Icon(
        Icons.keyboard_double_arrow_down_rounded,
        size: 48,
        color: Theme.of(context).colorScheme.grey,
      ),
    );
  }
}
