// import 'package:flutter/material.dart';
//
// class ListViewWithCentralWidget extends StatelessWidget {
//   final Widget centralWidget;
//
//   const ListViewWithCentralWidget({required this.centralWidget, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return ListView(
//           children: [
//             SizedBox(
//               height: constraints.maxHeight,
//               child: Center(
//                 child: centralWidget,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
