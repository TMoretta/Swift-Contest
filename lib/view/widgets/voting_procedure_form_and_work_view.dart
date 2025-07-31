import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
import 'package:swift_contest/model/db/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/voting_procedure_work_details_view.dart';

class VotingFormAndWorkView extends StatefulWidget {
  final bool isExcludedFromParticipant;
  final VotingSessionParticipation votingSessionParticipation;
  final List<VotingFormField> votingFormFields;
  final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap;

  const VotingFormAndWorkView({
    required this.isExcludedFromParticipant,
    required this.votingSessionParticipation,
    required this.votingFormFields,
    required this.votesMap,
    super.key,
  });

  @override
  State<VotingFormAndWorkView> createState() => _VotingFormAndWorkViewState();
}

class _VotingFormAndWorkViewState extends State<VotingFormAndWorkView> {
  late final bool isExcludedFromParticipant;
  late final VotingSessionParticipation votingSessionParticipation;
  late final List<VotingFormField> votingFormFields;
  late final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap;

  @override
  void initState() {
    super.initState();
    isExcludedFromParticipant = widget.isExcludedFromParticipant;
    votingSessionParticipation = widget.votingSessionParticipation;
    votingFormFields = widget.votingFormFields;
    votesMap = widget.votesMap;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VotingProcedureWorkDetailsView(
          participantFullName: votingSessionParticipation.participantFullName,
          workName: votingSessionParticipation.workName,
          workDescription: votingSessionParticipation.workDescription,
          workImagesUrls: votingSessionParticipation.workImagesUrls,
        ),
        Divider(height: 32),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 12),
            if (isExcludedFromParticipant)
              Text(
                'You have been excluded from voting to this participant',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            if (isExcludedFromParticipant) SizedBox(height: 12),
            for (var votingFormField in votingFormFields)
              Builder(
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          '${votingFormField.question} ${(votingFormField.isRequired) ? '*' : ''}'),
                      switch (votingFormField.type) {
                        VotingFormFieldType.textual => CustomTextFormField(
                            controller: votesMap[votingSessionParticipation]![votingFormField],
                            focusNode: FocusNode(),
                            borderType: InputBorderType.outlined,
                            enabled: isExcludedFromParticipant ? false : true,
                            autovalidateMode: AutovalidateMode.onUnfocus,
                            minLines: 2,
                            maxLines: 4,
                            label:
                                '${votingFormField.question} ${(votingFormField.isRequired) ? '*' : ''}',
                            keyboardType: TextInputType.text,
                            // prefixIcon:Icon(Icons.text_fields),
                            // suffixIcon: (votingFormField.type.isTextual)
                            //     ? null
                            //     : Row(
                            //         mainAxisSize: MainAxisSize.min,
                            //         children: [
                            //           SizedBox(width: 12),
                            //           Text(
                            //             '${prettyDouble(votingFormField.minValue!)} - ${prettyDouble(votingFormField.maxValue!)}',
                            //             // textAlign: TextAlign.center,
                            //             style: Theme.of(context).textTheme.labelLarge,
                            //           ),
                            //           SizedBox(width: 12),
                            //         ],
                            //       ),
                            validator: (isExcludedFromParticipant)
                                ? null
                                : (value) =>
                                     _validateTextualField(value, votingFormField.isRequired)
                                  ,
                          ),
                        VotingFormFieldType.slider => Slider(
                            min: votingFormField.sliderMinValue!.toDouble(),
                            max: votingFormField.sliderMaxValue!.toDouble(),
                            divisions: votingFormField.sliderMaxValue! - votingFormField.sliderMinValue!,
                            value: 0,
                            onChanged: (value) {
                              votesMap[votingSessionParticipation]![votingFormField]!.setText(value.toString());
                            },
                        ),
                      },
                      SizedBox(height: 12),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

String? _validateTextualField(String? value, bool isRequired) {
  if (value == null || value.trim().isEmpty) {
    return (isRequired) ? 'Required' : null;
  }
  return null;
}

String? _validateNumericField(String? value, double minValue, double maxValue, bool isRequired) {
  if (value == null || value.trim().isEmpty) {
    return (isRequired) ? 'Required' : null;
  }
  if (double.tryParse(value) == null) {
    return 'Must be a number';
  }
  final number = double.parse(value);
  if (!(number >= minValue && number <= maxValue)) {
    return 'The vote does not respect the boundaries';
  }
  return null;
}
