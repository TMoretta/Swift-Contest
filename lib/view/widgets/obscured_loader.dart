import 'package:flutter/material.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class ObscuredLoader extends StatelessWidget {
  const ObscuredLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withAlpha(40),
      child: Loader(),
    );
  }
}
