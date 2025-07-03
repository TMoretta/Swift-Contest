import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
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
                  if (state.sourceEvent is OrganizerVotingResultDetailsPageInit) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                case BlocStatus.failure:
                  if (state.sourceEvent is OrganizerVotingResultDetailsPageInit) {
                    return RefreshIndicator.adaptive(
                      onRefresh: () async {
                        context
                            .read<OrganizerVotingResultDetailsPageBloc>()
                            .add(OrganizerVotingResultDetailsPageInit(
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
                  late List<DataColumn> columnsHeaders;
                  late List<DataRow> rows;

                  if (participantsVotingsPerSimpleJurorMap.isEmpty) {
                    return ListViewWithCentralLabel(label: 'No vote submitted');
                  }

                  if (chosenSimpleJuror == null && chosenParticipationBundle == null) {
                    columnsHeaders = <DataColumn>[
                      DataColumn(label: Text('Participant')),
                      for (var simpleJuror in simpleJurors)
                        for (var field in votingFormFields)
                          DataColumn(
                            label: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(simpleJuror.fullName,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(field.name,
                                    style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                              ],
                            ),
                          ),
                    ];

                    rows = participationsBundles.map((participationBundle) {
                      return DataRow(
                        cells: <DataCell>[
                          DataCell(Text(participationBundle.participant.fullName)),
                          for (var simpleJuror in simpleJurors)
                            for (int i = 0; i < votingFormFields.length; i++)
                              DataCell(
                                Text(
                                  (participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                              participationBundle] !=
                                          null)
                                      ? participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                              participationBundle]![i]
                                          .simpleJurorVote
                                          .value
                                          .toString()
                                      : 'Excluded',
                                ),
                              ),
                        ],
                      );
                    }).toList();
                  }

                  if (chosenSimpleJuror != null && chosenParticipationBundle != null) {
                    columnsHeaders = <DataColumn>[
                      ...votingFormFields.map((e) => DataColumn(label: Text(e.name))),
                    ];

                    rows = [
                      DataRow(cells: [
                        for (int i = 0; i < votingFormFields.length; i++)
                          DataCell(
                            Text(
                              (participantsVotingsPerSimpleJurorMap[chosenSimpleJuror]![
                                          chosenParticipationBundle] !=
                                      null)
                                  ? participantsVotingsPerSimpleJurorMap[chosenSimpleJuror]![
                                          chosenParticipationBundle]![i]
                                      .simpleJurorVote
                                      .value
                                      .toString()
                                  : 'Excluded',
                            ),
                          ),
                      ])
                    ];
                  }

                  if (chosenSimpleJuror != null && chosenParticipationBundle == null) {
                    columnsHeaders = <DataColumn>[
                      const DataColumn(label: Text('Participant')),
                      ...votingFormFields.map((e) => DataColumn(label: Text(e.name))),
                    ];

                    rows = <DataRow>[
                      for (var participationBundle in participationsBundles)
                        DataRow(
                          cells: [
                            DataCell(Text(participationBundle.participant.fullName)),
                            for (int i = 0; i < votingFormFields.length; i++)
                              DataCell(
                                Text(
                                  (participantsVotingsPerSimpleJurorMap[chosenSimpleJuror]![
                                              participationBundle] !=
                                          null)
                                      ? participantsVotingsPerSimpleJurorMap[chosenSimpleJuror]![
                                              participationBundle]![i]
                                          .simpleJurorVote
                                          .value
                                          .toString()
                                      : 'Excluded',
                                ),
                              ),
                          ],
                        )
                    ];
                  }

                  if (chosenSimpleJuror == null && chosenParticipationBundle != null) {
                    columnsHeaders = <DataColumn>[
                      const DataColumn(label: Text('Juror')),
                      ...votingFormFields.map((e) => DataColumn(label: Text(e.name))),
                    ];

                    rows = <DataRow>[
                      for (var simpleJuror in simpleJurors)
                        DataRow(
                          cells: [
                            DataCell(Text(simpleJuror.fullName)),
                            for (int i = 0; i < votingFormFields.length; i++)
                              DataCell(
                                Text(
                                  (participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                              chosenParticipationBundle] !=
                                          null)
                                      ? participantsVotingsPerSimpleJurorMap[simpleJuror]![
                                              chosenParticipationBundle]![i]
                                          .simpleJurorVote
                                          .value
                                          .toString()
                                      : 'Excluded',
                                ),
                              ),
                          ],
                        ),
                    ];
                  }

                  return ListView(
                    children: [
                      Text('Juror'),
                      DropdownMenu(
                        enableSearch: false,
                        onSelected: (value) {
                          setState(() {
                            chosenSimpleJuror = value;
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
                      Text('Participant'),
                      DropdownMenu(
                        enableSearch: false,
                        onSelected: (value) {
                          setState(() {
                            chosenParticipationBundle = value;
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
                      if (chosenSimpleJuror == null && chosenParticipationBundle == null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: columnsHeaders,
                            rows: rows,
                          ),
                        ),
                      if (chosenSimpleJuror != null && chosenParticipationBundle != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: columnsHeaders,
                            rows: rows,
                          ),
                        ),
                      if (chosenSimpleJuror != null && chosenParticipationBundle == null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: columnsHeaders,
                            rows: rows,
                          ),
                        ),
                      if (chosenSimpleJuror == null && chosenParticipationBundle != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: columnsHeaders,
                            rows: rows,
                          ),
                        ),
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
