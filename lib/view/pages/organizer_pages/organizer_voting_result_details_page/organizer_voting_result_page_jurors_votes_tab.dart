import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';

class OrganizerVotingResultPageJurorsVotesTab extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingResultPageJurorsVotesTab({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingResultPageJurorsVotesTab> createState() =>
      _OrganizerVotingResultPageJurorsVotesTabState();
}

class _OrganizerVotingResultPageJurorsVotesTabState
    extends State<OrganizerVotingResultPageJurorsVotesTab> {
  late String votingSessionId;
  JurationBundle? chosenJurationBundle;
  ParticipationBundle? chosenParticipationBundle;

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<OrganizerVotingResultDetailsPageBloc, OrganizerVotingResultDetailsPageState>(
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return VoidWidget();
            case BlocStatus.loading:
              return Loader();
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
                  child: ListView(),
                );
              } else {
                continue successCase;
              }
            successCase:
            case BlocStatus.success:
              final votingSessionResultBundle = state.votingSessionResultBundle!;
              final votingFormFields = votingSessionResultBundle.votingFormBundle.votingFormFields;
              final List<JurationBundle> jurationsBundles = state
                  .votingSessionResultBundle!.participantsVotingsPerJurorMap.entries
                  .map((e) => e.key)
                  .toList(growable: false);
              final List<ParticipationBundle> participationsBundles = state
                  .votingSessionResultBundle!.jurorsVotingsPerParticipantMap.entries
                  .map((e) => e.key)
                  .toList(growable: false);
              final participantsVotingsPerJurorMap =
                  state.votingSessionResultBundle!.participantsVotingsPerJurorMap;
              late List<DataColumn> columnsHeaders;
              late List<DataRow> rows;

              if (participantsVotingsPerJurorMap.isEmpty) {
                return Center(
                  child: Text('No vote submitted'),
                );
              }

              if (chosenJurationBundle == null && chosenParticipationBundle == null) {
                columnsHeaders = <DataColumn>[
                  DataColumn(label: Text('Participant')),
                  for (var jurationBundle in jurationsBundles)
                    for (var field in votingFormFields)
                      DataColumn(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(jurationBundle.juror.fullName,
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
                      for (var jurationBundle in jurationsBundles)
                        for (int i = 0; i < votingFormFields.length; i++)
                          DataCell(
                            Text(
                              (participantsVotingsPerJurorMap[jurationBundle]![
                                          participationBundle] !=
                                      null)
                                  ? participantsVotingsPerJurorMap[jurationBundle]![
                                          participationBundle]![i]
                                      .jurorVote
                                      .value
                                      .toString()
                                  : 'Excluded',
                            ),
                          ),
                    ],
                  );
                }).toList();
              }

              if (chosenJurationBundle != null && chosenParticipationBundle != null) {
                columnsHeaders = <DataColumn>[
                  ...votingFormFields.map((e) => DataColumn(label: Text(e.name))),
                ];

                rows = [
                  DataRow(cells: [
                    for (int i = 0; i < votingFormFields.length; i++)
                      DataCell(
                        Text(
                          (participantsVotingsPerJurorMap[chosenJurationBundle]![
                                      chosenParticipationBundle] !=
                                  null)
                              ? participantsVotingsPerJurorMap[chosenJurationBundle]![
                                      chosenParticipationBundle]![i]
                                  .jurorVote
                                  .value
                                  .toString()
                              : 'Excluded',
                        ),
                      ),
                  ])
                ];
              }

              if (chosenJurationBundle != null && chosenParticipationBundle == null) {
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
                              (participantsVotingsPerJurorMap[chosenJurationBundle]![
                                          participationBundle] !=
                                      null)
                                  ? participantsVotingsPerJurorMap[chosenJurationBundle]![
                                          participationBundle]![i]
                                      .jurorVote
                                      .value
                                      .toString()
                                  : 'Excluded',
                            ),
                          ),
                      ],
                    )
                ];
              }

              if (chosenJurationBundle == null && chosenParticipationBundle != null) {
                columnsHeaders = <DataColumn>[
                  const DataColumn(label: Text('Juror')),
                  ...votingFormFields.map((e) => DataColumn(label: Text(e.name))),
                ];

                rows = <DataRow>[
                  for (var jurationBundle in jurationsBundles)
                    DataRow(
                      cells: [
                        DataCell(Text(jurationBundle.juror.fullName)),
                        for (int i = 0; i < votingFormFields.length; i++)
                          DataCell(
                            Text(
                              (participantsVotingsPerJurorMap[jurationBundle]![
                                          chosenParticipationBundle] !=
                                      null)
                                  ? participantsVotingsPerJurorMap[jurationBundle]![
                                          chosenParticipationBundle]![i]
                                      .jurorVote
                                      .value
                                      .toString()
                                  : 'Excluded',
                            ),
                          ),
                      ],
                    ),
                ];
              }

              return RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<OrganizerVotingResultDetailsPageBloc>()
                    .add(OrganizerVotingResultDetailsPageRefresh(votingSessionId: votingSessionId)),
                child: ListView(
                  children: [
                    Text('Juror'),
                    DropdownMenu(
                      enableSearch: false,
                      onSelected: (value) {
                        setState(() {
                          chosenJurationBundle = value;
                        });
                      },
                      dropdownMenuEntries: [
                        DropdownMenuEntry(
                          value: null,
                          label: 'All',
                        ),
                        for (var jurationBundle in jurationsBundles)
                          DropdownMenuEntry(
                            value: jurationBundle,
                            label: jurationBundle.juror.fullName,
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
                    if (chosenJurationBundle == null && chosenParticipationBundle == null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: columnsHeaders,
                          rows: rows,
                        ),
                      ),
                    if (chosenJurationBundle != null && chosenParticipationBundle != null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: columnsHeaders,
                          rows: rows,
                        ),
                      ),
                    if (chosenJurationBundle != null && chosenParticipationBundle == null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: columnsHeaders,
                          rows: rows,
                        ),
                      ),
                    if (chosenJurationBundle == null && chosenParticipationBundle != null)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: columnsHeaders,
                          rows: rows,
                        ),
                      ),
                  ],
                ),
              );
          }
        },
      ),
      floatingActionButton:
          BlocBuilder<OrganizerVotingResultDetailsPageBloc, OrganizerVotingResultDetailsPageState>(
        builder: (context, state) {
          if (state.status.isInitial) {
            return VoidWidget();
          }
          return FloatingActionButton.extended(
            onPressed: (!state.status.isLoading)
                ? () {
                    context.pushNamed(AppRouter.organizerVotingResultExport,
                        extra: votingSessionId);
                  }
                : null,
            elevation: 1,
            label: Text('Export'),
          );
        },
      ),
    );
  }
}
