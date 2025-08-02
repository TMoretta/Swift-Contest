// import 'package:flutter/material.dart';
// import 'package:swift_contest/model/database/entities/voting_form_field.dart';
// import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
// import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
// import 'package:swift_contest/view/widgets/custom_slider_form_field.dart';
// import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
// import 'package:swift_contest/view/widgets/voting_procedure_work_details_view.dart';
//
// class VotingFormAndWorkView extends StatefulWidget {
//   final bool isExcludedFromParticipant;
//   final VotingSessionParticipant votingSessionParticipation;
//   final List<VotingFormField> votingFormFields;
//   final Map<VotingSessionParticipant, Map<VotingFormField, TextEditingController>> participantFieldsValuesMap;
//
//   const VotingFormAndWorkView({
//     required this.isExcludedFromParticipant,
//     required this.votingSessionParticipation,
//     required this.votingFormFields,
//     required this.participantFieldsValuesMap,
//     super.key,
//   });
//
//   @override
//   State<VotingFormAndWorkView> createState() => _VotingFormAndWorkViewState();
// }
//
// class _VotingFormAndWorkViewState extends State<VotingFormAndWorkView> {
//   late final bool isExcludedFromParticipant;
//   late final VotingSessionParticipant votingSessionParticipation;
//   late final List<VotingFormField> votingFormFields;
//   late final Map<VotingSessionParticipant, Map<VotingFormField, TextEditingController>> participantFieldsValuesMap;
//
//   @override
//   void initState() {
//     super.initState();
//     isExcludedFromParticipant = widget.isExcludedFromParticipant;
//     votingSessionParticipation = widget.votingSessionParticipation;
//     votingFormFields = widget.votingFormFields;
//     participantFieldsValuesMap = widget.participantFieldsValuesMap;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         VotingProcedureWorkDetailsView(
//           participantFullName: votingSessionParticipation.participantFullName,
//           workName: votingSessionParticipation.workName,
//           workDescription: votingSessionParticipation.workDescription,
//           workImagesUrls: votingSessionParticipation.workImagesUrls,
//         ),
//         Divider(height: 32),
//         Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Form',
//               style: Theme.of(context)
//                   .textTheme
//                   .titleLarge
//                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
//             ),
//             if (isExcludedFromParticipant)
//               Padding(
//                 padding: const EdgeInsets.only(top: 12),
//                 child: Text(
//                   'You have been excluded from voting to this participant',
//                   style: Theme.of(context)
//                       .textTheme
//                       .bodyLarge
//                       ?.copyWith(color: Theme.of(context).colorScheme.error),
//                 ),
//               ),
//             SizedBox(height: 12),
//             for (var votingFormField in votingFormFields)
//               Builder(
//                 builder: (context) {
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${votingFormField.question} ${(votingFormField.isRequired) ? '*' : ''}',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       SizedBox(height: 8),
//                       switch (votingFormField.type) {
//                         VotingFormFieldType.textual => CustomTextFormField(
//                             controller: participantFieldsValuesMap[votingSessionParticipation]![votingFormField]!,
//                             focusNode: FocusNode(),
//                             borderType: InputBorderType.outlined,
//                             enabled: isExcludedFromParticipant ? false : true,
//                             autovalidateMode: AutovalidateMode.onUnfocus,
//                             minLines: 1,
//                             maxLines: 4,
//                             label: '${votingFormField.question} ${(votingFormField.isRequired) ? '*' : ''}',
//                             validator: (isExcludedFromParticipant)
//                                 ? null
//                                 : (value) =>
//                                     _validateTextualField(value, votingFormField.isRequired),
//                           ),
//                         VotingFormFieldType.slider => CustomSliderFormField(
//                           controller: participantFieldsValuesMap[votingSessionParticipation]![votingFormField]!,
//                           votingFormField: votingFormField,
//                           isEnabled: !isExcludedFromParticipant,
//                         ),
//                         // VotingFormFieldType.slider => Slider(
//                         //     min: field.sliderMinValue!.toDouble(),
//                         //     max: field.sliderMaxValue!.toDouble(),
//                         //     divisions: field.sliderMaxValue! - field.sliderMinValue!,
//                         //     value: double.parse(votesMap[votingSessionParticipation]![field]!.text),
//                         //     onChanged: isExcludedFromParticipant ? null : (value) {
//                         //       setState(() {
//                         //       votesMap[votingSessionParticipation]![field]!.setText(value.toString());
//                         //
//                         //       });
//                         //     },
//                         //   label: votesMap[votingSessionParticipation]![field]!.text,
//                         // ),
//                       },
//                     ],
//                   );
//                 },
//               ),
//                       SizedBox(height: 100),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// String? _validateTextualField(String? value, bool isRequired) {
//   if (value == null || value.trim().isEmpty) {
//     return (isRequired) ? 'Required' : null;
//   }
//   return null;
// }
//
// String? _validateNumericField(String? value, double minValue, double maxValue, bool isRequired) {
//   if (value == null || value.trim().isEmpty) {
//     return (isRequired) ? 'Required' : null;
//   }
//   if (double.tryParse(value) == null) {
//     return 'Must be a number';
//   }
//   final number = double.parse(value);
//   if (!(number >= minValue && number <= maxValue)) {
//     return 'The vote does not respect the boundaries';
//   }
//   return null;
// }
