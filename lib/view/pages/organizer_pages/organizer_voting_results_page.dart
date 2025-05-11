import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/bloc_status.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_results_page_bloc/organizer_voting_results_page_bloc.dart';

class OrganizerVotingResultsPage extends StatefulWidget {
  final String contestId;
  final String votingSessionId;

  const OrganizerVotingResultsPage({
    super.key,
    required this.contestId,
    required this.votingSessionId,
  });

  @override
  State<OrganizerVotingResultsPage> createState() => _OrganizerVotingResultsPageState();
}

class _OrganizerVotingResultsPageState extends State<OrganizerVotingResultsPage> {
  late User user;
  Participant? chosenParticipant;
  Juror? chosenJuror;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizerVotingResultsPageBloc>(
      create: (context) => OrganizerVotingResultsPageBloc(
        votingSessionRepository: context.read(),
        profileRepository: context.read(),
        votingSessionParticipantRepository: context.read(),
        votingSessionJurorRepository: context.read(),
        votingRepository: context.read(),
        voteRepository: context.read(),
        votingFormRepository: context.read(),
        votingFormFieldRepository: context.read(),
      )..add(OrganizerVotingResultsPageGetResultsInfo(votingSessionId: widget.votingSessionId)),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Results'),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Align(
                          alignment: Alignment.center,
                          child: Card(
                            elevation: 0.5,
                            child: TabBar(
                              labelColor: Theme.of(context).colorScheme.white,
                              unselectedLabelColor: Theme.of(context).colorScheme.grey7,
                              isScrollable: true,
                              dividerColor: Colors.transparent,
                              tabAlignment: TabAlignment.center,
                              splashBorderRadius: BorderRadius.circular(16),
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              tabs: [
                                Tab(text: 'Info'),
                                Tab(text: 'Votes'),
                                Tab(text: 'Ranking'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            children: [
                              OrganizerVotingResultsInfoTab(),
                              OrganizerVotingResultsVotesTab(),
                              OrganizerVotingResultsCompleteTab(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class OrganizerVotingResultsInfoTab extends StatefulWidget {
  const OrganizerVotingResultsInfoTab({super.key});

  @override
  State<OrganizerVotingResultsInfoTab> createState() => _OrganizerVotingResultsInfoTabState();
}

class _OrganizerVotingResultsInfoTabState extends State<OrganizerVotingResultsInfoTab> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingResultsPageBloc, OrganizerVotingResultsPageState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state.status.isLoading) {
          return Loader();
        }
        if (state.status.isSuccess) {
          return ListView(
            children: [
              Text('Jurors that did\'t submit'),
              if (state.jurorsThatNotSubmitted!.isNotEmpty)
                for (var jurorThatNotSubmitted in state.jurorsThatNotSubmitted!)
                  ListTile(
                    title: Text(jurorThatNotSubmitted.fullName),
                  ),
              if (state.jurorsThatNotSubmitted!.isEmpty) Text('None'),
              SizedBox(
                height: 12,
              ),
              Text('Simple jurors'),
            ],
          );
        }
        return Container();
      },
    );
  }
}

class OrganizerVotingResultsVotesTab extends StatefulWidget {
  const OrganizerVotingResultsVotesTab({super.key});

  @override
  State<OrganizerVotingResultsVotesTab> createState() =>
      _OrganizerVotingResultsVotesTabState();
}

class _OrganizerVotingResultsVotesTabState extends State<OrganizerVotingResultsVotesTab> {
  Juror? chosenJuror;
  Participant? chosenParticipant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<OrganizerVotingResultsPageBloc, OrganizerVotingResultsPageState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status.isLoading) {
            return Loader();
          }
          if (state.status.isSuccess) {
            final List<String> fields = state.votingFormFields!.map((e) => e.name).toList(growable: false);
            final List<Juror> jurorsThatSubmitted = state.jurorsThatSubmitted!;
            final List<Participant> participants = state.participants!;
            final votesPerJurorMap = state.votesPerJurorMap!;
            final votesPerParticipantMap = state.votesPerParticipantMap!;
            final participantsExclusionsPerJurorMap = state.participantsExclusionsPerJurorMap!;
            late List<DataColumn> columnsHeaders;
            late List<DataRow> rows;

            if(chosenJuror == null && chosenParticipant==null) {
              columnsHeaders = <DataColumn>[
                DataColumn(label: Text('Participant')),
                for (var juror in jurorsThatSubmitted)
                  for (var field in fields)
                    DataColumn(
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(juror.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(field, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                        ],
                      ),
                    ),
              ];

              rows = participants.map((participant) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(participant.fullName)),
                    for (var juror in jurorsThatSubmitted)
                      for (int i = 0; i < fields.length; i++)
                        DataCell(
                          Text(
                            (votesPerParticipantMap[participant]![juror] != null)
                                ? votesPerParticipantMap[participant]![juror]![i]
                                .value
                                : 'Excluded',
                          ),
                        ),
                  ],
                );
              }).toList();
            }

            if (chosenJuror != null && chosenParticipant != null) {
              columnsHeaders = <DataColumn>[
                ...fields.map((e) => DataColumn(label: Text(e))),
              ];

              final participantVotes = votesPerJurorMap[chosenJuror]![chosenParticipant];
              if (participantsExclusionsPerJurorMap[chosenJuror]!
                  .contains(chosenParticipant)) {
                rows = <DataRow>[
                  DataRow(cells: [
                    for (int i = 0; i < fields.length; i++) DataCell(Text('Excluded')),
                  ])
                ];
              } else {
                rows = <DataRow>[
                  DataRow(cells: [
                    ...participantVotes!.map((e) {
                      return DataCell(Text(e.value));
                    }),
                  ])
                ];
              }
            }

            if (chosenJuror != null && chosenParticipant == null) {
              columnsHeaders = <DataColumn>[
                const DataColumn(label: Text('Participant')),
                ...fields.map((e) => DataColumn(label: Text(e))),
              ];

              final votesPerParticipant = votesPerJurorMap[chosenJuror]!;

              rows = <DataRow>[
                for (var participantVotes in votesPerParticipant.entries)
                  DataRow(
                    cells: [
                      DataCell(Text(participantVotes.key.fullName)),
                      if (participantsExclusionsPerJurorMap[chosenJuror]!
                          .contains(participantVotes.key))
                        for (int i = 0; i < fields.length; i++) DataCell(Text('Excluded')),
                      if (participantVotes.value != null)
                        ...participantVotes.value!.map((e) => DataCell(Text(e.value))),
                    ],
                  )
              ];
            }

            if (chosenJuror == null && chosenParticipant != null) {
              columnsHeaders = <DataColumn>[
                const DataColumn(label: Text('Juror')),
                ...fields.map((e) => DataColumn(label: Text(e))),
              ];

              final votesPerJuror = votesPerParticipantMap[chosenParticipant]!;
              rows = <DataRow>[
                for (var jurorVotes in votesPerJuror.entries)
                  DataRow(
                    cells: [
                      DataCell(Text(jurorVotes.key.fullName)),
                      if (participantsExclusionsPerJurorMap[jurorVotes.key]!
                          .contains(chosenParticipant))
                        for (int i = 0; i < fields.length; i++) DataCell(Text('Excluded')),
                      if (jurorVotes.value != null)
                        ...jurorVotes.value!.map((e) => DataCell(Text(e.value))),
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
                      chosenJuror = value;
                    });
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: null,
                      label: 'All',
                    ),
                    for (var jurorThatSubmitted in jurorsThatSubmitted)
                      DropdownMenuEntry(
                        value: jurorThatSubmitted,
                        label: jurorThatSubmitted.fullName,
                      ),
                  ],
                ),
                Text('Participant'),
                DropdownMenu(
                  enableSearch: false,
                  onSelected: (value) {
                    setState(() {
                      chosenParticipant = value;
                    });
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                      value: null,
                      label: 'All',
                    ),
                    for (var participant in participants)
                      DropdownMenuEntry(
                        value: participant,
                        label: participant.fullName,
                      ),
                  ],
                ),
                if (chosenJuror == null && chosenParticipant == null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: columnsHeaders,
                      rows: rows,
                    ),
                  ),
                if (chosenJuror != null && chosenParticipant != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: columnsHeaders,
                      rows: rows,
                    ),
                  ),
                if (chosenJuror != null && chosenParticipant == null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: columnsHeaders,
                      rows: rows,
                    ),
                  ),
                if (chosenJuror == null && chosenParticipant != null)
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
          return Container();
        },
      ),
      floatingActionButton:
          BlocConsumer<OrganizerVotingResultsPageBloc, OrganizerVotingResultsPageState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state.status.isSuccess) {
            return FloatingActionButton(
              onPressed: () {
                final votingSessionJson = state.votingSession!.toJson();
                final participantsJson =
                    state.participants!.map((e) => e.toJson()).toList(growable: false);
                final jurorsThatSubmittedJson =
                    state.jurorsThatSubmitted!.map((e) => e.toJson()).toList(growable: false);
                final jurorsThatNotSubmittedJson =
                    state.jurorsThatNotSubmitted!.map((e) => e.toJson()).toList(growable: false);
                final votingFormFieldsJson =
                    state.votingFormFields!.map((e) => e.toJson()).toList(growable: false);
                final votesPerJurorMapJson = state.votesPerJurorMap!.map(
                  (key, value) {
                    final jurorJson = key.toJson();
                    final participantAndVotesJson = value.map(
                      (key, value) {
                        final participantJson = key.toJson();
                        final List<Map<String, dynamic>>? votesJson = (value != null)
                            ? value.map((e) => e.toJson()).toList(growable: false)
                            : null;
                        return MapEntry(participantJson, votesJson);
                      },
                    );
                    return MapEntry(jurorJson, participantAndVotesJson);
                  },
                );
                final votesPerParticipantMapJson = state.votesPerParticipantMap!.map(
                  (key, value) {
                    final participantJson = key.toJson();
                    final jurorAndVotesJson = value.map(
                      (key, value) {
                        final jurorJson = key.toJson();
                        final List<Map<String, dynamic>>? votesJson = (value != null)
                            ? value.map((e) => e.toJson()).toList(growable: false)
                            : null;
                        return MapEntry(jurorJson, votesJson);
                      },
                    );
                    return MapEntry(participantJson, jurorAndVotesJson);
                  },
                );

                final participantsExclusionsPerJurorMapJson =
                    state.participantsExclusionsPerJurorMap!.map((key, value) {
                  final jurorJson = key.toJson();
                  final List<Map<String, dynamic>> participantsExclusionsJson =
                      value.map((e) => e.toJson()).toList(growable: false);
                  return MapEntry(jurorJson, participantsExclusionsJson);
                });

                final Map<String, dynamic> data = {
                  'voting_session' : votingSessionJson,
                  'participants': participantsJson,
                  'jurors_that_submitted': jurorsThatSubmittedJson,
                  'jurors_that_not_submitted': jurorsThatNotSubmittedJson,
                  'voting_form_fields': votingFormFieldsJson,
                  'votes_per_juror_map': votesPerJurorMapJson,
                  'votes_per_participant_map': votesPerParticipantMapJson,
                  'participants_exclusions_per_juror_map': participantsExclusionsPerJurorMapJson,
                };

                context.pushNamed(AppRouter.organizerVotingResultsExport, extra: data);
              },
              child: Text('Export'),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class OrganizerVotingResultsCompleteTab extends StatefulWidget {
  const OrganizerVotingResultsCompleteTab({super.key});

  @override
  State<OrganizerVotingResultsCompleteTab> createState() =>
      _OrganizerVotingResultsCompleteTabState();
}

class _OrganizerVotingResultsCompleteTabState extends State<OrganizerVotingResultsCompleteTab> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
