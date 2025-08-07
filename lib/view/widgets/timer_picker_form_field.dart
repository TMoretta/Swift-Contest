// import 'package:flutter/material.dart';
// import 'package:numberpicker/numberpicker.dart';
//
// class TimerPickerFormField extends StatefulWidget {
//   final int minutes;
//   final int seconds;
//   final void Function(int, int) onChanged;
//   final String? Function(Duration?)? validator;
//
//   const TimerPickerFormField({
//     required this.minutes,
//     required this.seconds,
//     required this.onChanged,
//     this.validator,
//     super.key,
//   });
//
//   @override
//   State<TimerPickerFormField> createState() => _TimerPickerFormFieldState();
// }
//
// class _TimerPickerFormFieldState extends State<TimerPickerFormField> {
//   late int minutes;
//   late int seconds;
//   late final void Function(int, int) onChanged;
//   late final String? Function(Duration?)? validator;
//
//   @override
//   void initState() {
//     super.initState();
//     minutes = widget.minutes;
//     seconds = widget.seconds;
//     onChanged = widget.onChanged;
//     validator = widget.validator;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: Padding(
//         padding: EdgeInsets.all(8),
//         child: FormField(
//           validator: widget.validator,
//           builder: (field) {
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.min,
//                   spacing: 8,
//                   children: [
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       spacing: 4,
//                       children: [
//                         Text(
//                           'Minutes',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         NumberPicker(
//                           itemCount: 1,
//                           minValue: 0,
//                           maxValue: 59,
//                           value: minutes,
//                           onChanged: (value) {
//                             setState(() {
//                               minutes = value;
//                             });
//                             onChanged(minutes, seconds);
//                           },
//                         ),
//                       ],
//                     ),
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       spacing: 4,
//                       children: [
//                         Text(
//                           'Seconds',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         NumberPicker(
//                           itemCount: 1,
//                           minValue: 0,
//                           maxValue: 59,
//                           value: seconds,
//                           onChanged: (value) {
//                             setState(() {
//                               seconds = value;
//                             });
//                             onChanged(minutes, seconds);
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 if (field.hasError) SizedBox(height: 4),
//                 if (field.hasError)
//                   Text(
//                     field.errorText!,
//                     style: Theme.of(context)
//                         .textTheme
//                         .labelMedium
//                         ?.copyWith(color: Theme.of(context).colorScheme.error),
//                   ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
