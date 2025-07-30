import 'package:flutter/material.dart';
import 'package:swift_contest/model/db/entities/voting_form_field.dart';
import 'package:swift_contest/model/db/entities/voting_session_participation.dart';
import 'package:swift_contest/model/db/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/voting_procedure_work_details_view.dart';

class VotingProcedureFormAndWorkView extends StatefulWidget {
  final bool isExcludedFromParticipant;
  final VotingSessionParticipation votingSessionParticipation;
  final List<VotingFormField> votingFormFields;
  final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap;

  const VotingProcedureFormAndWorkView({
    required this.isExcludedFromParticipant,
    required this.votingSessionParticipation,
    required this.votingFormFields,
    required this.votesMap,
    super.key,
  });

  @override
  State<VotingProcedureFormAndWorkView> createState() => _VotingProcedureFormAndWorkViewState();
}

class _VotingProcedureFormAndWorkViewState extends State<VotingProcedureFormAndWorkView> {
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
                      CustomTextFormField(
                        controller: votesMap[votingSessionParticipation]![votingFormField],
                        focusNode: FocusNode(),
                        borderType: InputBorderType.outlined,
                        enabled: isExcludedFromParticipant ? false : true,
                        autovalidateMode: AutovalidateMode.onUnfocus,
                        minLines: (votingFormField.type.isTextual) ? 2 : 1,
                        maxLines: (votingFormField.type.isTextual) ? 4 : 1,
                        label: '${votingFormField.name} ${(votingFormField.isRequired) ? '*' : ''}',
                        keyboardType: (votingFormField.type.isTextual)
                            ? TextInputType.text
                            : TextInputType.number,
                        prefixIcon: (votingFormField.type.isTextual)
                            ? Icon(Icons.text_fields)
                            : Icon(Icons.numbers),
                        suffixIcon: (votingFormField.type.isTextual)
                            ? null : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 12),
                                  Text(
                                    '${prettyDouble(votingFormField.minValue!)} - ${prettyDouble(votingFormField.maxValue!)}',
                                    // textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  SizedBox(width: 12),
                                ],
                              ),
                        validator: (isExcludedFromParticipant)
                            ? null
                            : (value) {
                                return (votingFormField.type.isTextual)
                                    ? _validateTextualField(value, votingFormField.isRequired)
                                    : _validateNumericField(value, votingFormField.minValue!,
                                        votingFormField.maxValue!,  votingFormField.isRequired);
                              },
                      ),
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
