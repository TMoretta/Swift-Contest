import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/db/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingResultPageSimpleJurorsVotesTab extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingResultPageSimpleJurorsVotesTab({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingResultPageSimpleJurorsVotesTab> createState() =>
      _OrganizerVotingResultPageSimpleJurorsVotesTabState();
}

class _OrganizerVotingResultPageSimpleJurorsVotesTabState
    extends State<OrganizerVotingResultPageSimpleJurorsVotesTab> {
  late final String votingSessionId;
  SimpleJuror? chosenSimpleJuror;
  ParticipationBundle? chosenParticipationBundle;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizerVotingResultDetailsPageBloc, OrganizerVotingResultDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: Builder(
            builder: (context) {
              switch (state.status) {
                case BlocStatus.initial:
                  return VoidWidget();
                case BlocStatus.loading:
                  if (!state.isInitialized) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                case BlocStatus.failure:
                  if (!state.isInitialized) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async {
                        context
                            .read<OrganizerVotingResultDetailsPageBloc>()
                            .add(OrganizerVotingResultDetailsPageFetch(
                              votingSessionId: votingSessionId,
                            ));
                      },
                      child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                    );
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  final votingSessionResultBundle = state.votingSessionResultBundle!;
                  final votingFormFields =
                      votingSessionResultBundle.votingFormBundle.votingFormFields;
                  final List<SimpleJuror> simpleJurors = state
                      .votingSessionResultBundle!.votingSessionSimpleJurorsBundles
                      .map((e) => e.simpleJuror)
                      .toList(growable: false);
                  final List<ParticipationBundle> participationsBundles = state
                      .votingSessionResultBundle!.simpleJurorsVotingsPerParticipantMap.entries
                      .map((e) => e.key)
                      .toList(growable: false);
                  final participantsVotingsPerSimpleJurorMap =
                      state.votingSessionResultBundle!.participantsVotingsPerSimpleJurorMap;
                  List<DataColumn> columnsHeaders = [];
                  List<DataRow> rows = [];

                  if (participantsVotingsPerSimpleJurorMap.isEmpty) {
                    return ListViewWithCentralLabel(label: 'No vote submitted');
                  }

                  //* Table headers
                  if (chosenParticipationBundle != null) {
                    columnsHeaders = <DataColumn>[
                      DataColumn(label: VoidWidget()),
                      for (var field in votingFormFields)
                        DataColumn(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                chosenParticipationBundle!.participant.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                              ),
                              Text(
                                field.name,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ),
                    ];
                  } else {
                    columnsHeaders = <DataColumn>[
                      DataColumn(label: VoidWidget()),
                      for (var participationBundle in participationsBundles)
                        for (var field in votingFormFields)
                          DataColumn(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  participationBundle.participant.fullName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                                ),
                                Text(
                                  field.name,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                    ];
                  }

                  if (chosenSimpleJuror == null && chosenParticipationBundle == null) {
                    rows.clear();
                    for (var simpleJuror in simpleJurors) {
                      rows.add(
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                simpleJuror.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            for (var participationBundle in participationsBundles)
                              for (int i = 0; i < votingFormFields.length; i++)
                                DataCell(
                                  Text(
                                    participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                            participationBundle]![i]
                                        .simpleJurorVote
                                        .value
                                        .toString(),
                                  ),
                                ),
                          ],
                        ),
                      );
                    }
                  }

                  if (chosenSimpleJuror != null && chosenParticipationBundle != null) {
                    rows.clear();
                    rows.add(
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              chosenSimpleJuror!.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          for (int i = 0; i < votingFormFields.length; i++)
                            DataCell(
                              Text(
                                participantsVotingsPerSimpleJurorMap[chosenSimpleJuror!]![
                                        chosenParticipationBundle!]![i]
                                    .simpleJurorVote
                                    .value
                                    .toString(),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  if (chosenSimpleJuror != null && chosenParticipationBundle == null) {
                    rows.clear();
                    rows.add(
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              chosenSimpleJuror!.fullName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          for (var participationBundle in participationsBundles)
                            for (int i = 0; i < votingFormFields.length; i++)
                              DataCell(
                                Text(
                                  participantsVotingsPerSimpleJurorMap[chosenSimpleJuror!]![
                                          participationBundle]![i]
                                      .simpleJurorVote
                                      .value
                                      .toString(),
                                ),
                              ),
                        ],
                      ),
                    );
                  }

                  if (chosenSimpleJuror == null && chosenParticipationBundle != null) {
                    rows.clear();
                    for (var simpleJuror in simpleJurors) {
                      rows.add(
                        DataRow(
                          cells: [
                            DataCell(
                              Text(
                                simpleJuror.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            for (int i = 0; i < votingFormFields.length; i++)
                              DataCell(
                                Text(
                                  participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                          chosenParticipationBundle!]![i]
                                      .simpleJurorVote
                                      .value
                                      .toString(),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                  }

                  return ListView(
                    children: [
                      SizedBox(height: 16),
                      DropdownMenu(
                        label: Text('Simple juror'),
                        enableSearch: false,
                        maxLines: 1,
                        textStyle: Theme.of(context).textTheme.labelLarge,
                        onSelected: (value) {
                          setState(() {
                            chosenSimpleJuror = value;
                            columnsHeaders = columnsHeaders;
                            rows = rows;
                          });
                        },
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: null,
                            label: 'All',
                          ),
                          for (var simpleJuror in simpleJurors)
                            DropdownMenuEntry(
                              value: simpleJuror,
                              label: simpleJuror.fullName,
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      DropdownMenu(
                        label: Text('Participant'),
                        enableSearch: false,
                        maxLines: 1,
                        textStyle: Theme.of(context).textTheme.labelLarge,
                        onSelected: (value) {
                          setState(() {
                            chosenParticipationBundle = value;
                            columnsHeaders = columnsHeaders;
                            rows = rows;
                          });
                        },
                        dropdownMenuEntries: [
                          DropdownMenuEntry(
                            value: null,
                            label: 'All',
                          ),
                          for (var participationBundle in participationsBundles)
                            DropdownMenuEntry(
                              value: participationBundle,
                              label: participationBundle.participant.fullName,
                            ),
                        ],
                      ),
                      SizedBox(height: 24),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: columnsHeaders,
                          rows: rows,
                        ),
                      ),
                      SizedBox(height: 72),
                    ],
                  );
              }
            },
          ),
        );
      },
    );
  }
}
