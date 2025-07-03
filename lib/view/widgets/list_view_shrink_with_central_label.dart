import 'package:flutter/material.dart';

class ListViewShrinkWithCentralLabel extends StatelessWidget {
  final String label;

  const ListViewShrinkWithCentralLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
