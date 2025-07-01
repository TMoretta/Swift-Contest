import 'package:flutter/material.dart';
import 'package:swift_contest/view/widgets/loader.dart';

class ObscuredLoader extends StatelessWidget {
  const ObscuredLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.black45,
      child: Loader(),
    );
  }
}
