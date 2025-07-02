import 'package:flutter/material.dart';

class ListViewWithCentralLabel extends StatelessWidget {
  final String label;

  const ListViewWithCentralLabel({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
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
