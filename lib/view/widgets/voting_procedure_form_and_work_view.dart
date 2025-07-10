import 'package:flutter/material.dart';
import 'package:swift_contest/model/bundles/voting_session_participation_bundle.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session_participation.dart';
import 'package:swift_contest/model/data_models/work.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/voting_procedure_work_details_view.dart';

class VotingProcedureFormAndWorkView extends StatefulWidget {
  final bool isExcludedFromParticipant;
  final VotingSessionParticipationBundle votingSessionParticipationBundle;
  final List<VotingFormField> votingFormFields;
  final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap;

  const VotingProcedureFormAndWorkView({
    required this.isExcludedFromParticipant,
    required this.votingSessionParticipationBundle,
    required this.votingFormFields,
    required this.votesMap,
    super.key,
  });

  @override
  State<VotingProcedureFormAndWorkView> createState() => _VotingProcedureFormAndWorkViewState();
}

class _VotingProcedureFormAndWorkViewState extends State<VotingProcedureFormAndWorkView> {
  late final bool isExcludedFromParticipant;
  late final List<VotingFormField> votingFormFields;
  late final Map<VotingSessionParticipation, Map<VotingFormField, TextEditingController>> votesMap;
  late final VotingSessionParticipation votingSessionParticipation;
  late final Work work;
  late final Profile participant;

  @override
  void initState() {
    super.initState();
    isExcludedFromParticipant = widget.isExcludedFromParticipant;
    votingFormFields = widget.votingFormFields;
    votesMap = widget.votesMap;
    final votingSessionParticipationBundle = widget.votingSessionParticipationBundle;
    votingSessionParticipation = votingSessionParticipationBundle.votingSessionParticipation;
    work = votingSessionParticipationBundle.participationBundle.work!;
    participant = votingSessionParticipationBundle.participationBundle.participant;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VotingProcedureWorkDetailsView(
          work: work,
          participant: participant,
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
                        label: votingFormField.name,
                        keyboardType: TextInputType.number,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 12),
                            Text(
                              '${prettyDouble(votingFormField.minValue)} - ${prettyDouble(votingFormField.maxValue)}',
                              // textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SizedBox(width: 12),
                          ],
                        ),
                        validator: (isExcludedFromParticipant)
                            ? null
                            : (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Must be a number';
                                }
                                final number = double.parse(value);
                                if (!(number >= votingFormField.minValue &&
                                    number <= votingFormField.maxValue)) {
                                  return 'The vote does not respect the boundaries';
                                }
                                return null;
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
