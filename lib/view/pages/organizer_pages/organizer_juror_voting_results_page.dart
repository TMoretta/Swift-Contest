import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/voting_form_submission_value_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_juror_voting_results_page_bloc/organizer_juror_voting_results_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerJurorVotingResultsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJurorId;

  const OrganizerJurorVotingResultsPage({
    @PathParam('votingSessionJurorId') required this.votingSessionJurorId,
    super.key,
  });

  @override
  State<OrganizerJurorVotingResultsPage> createState() => _OrganizerJurorVotingResultsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJurorVotingResultsPageBloc>(
      create: (context) => OrganizerJurorVotingResultsPageBloc(
        organizerRepository: context.read(),
      )..add(OrganizerJurorVotingResultsPageFetch(votingSessionJurorId: votingSessionJurorId)),
      child: this,
    );
  }
}

class _OrganizerJurorVotingResultsPageState extends State<OrganizerJurorVotingResultsPage> {
  late String votingSessionJurorId;
  VotingSessionParticipant? chosenVotingSessionParticipant;

  @override
  void initState() {
    super.initState();
    votingSessionJurorId = widget.votingSessionJurorId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJurorVotingResultsPageBloc, OrganizerJurorVotingResultsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(
              title: state.votingSessionJurorResultBundle?.votingFormSubmissionBundle
                      .votingSessionJuror.jurorFullName ??
                  ''),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context
                              .read<OrganizerJurorVotingResultsPageBloc>()
                              .add(OrganizerJurorVotingResultsPageFetch(
                                  votingSessionJurorId: votingSessionJurorId)),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }

                  final votingFormBundle = state.votingSessionJurorResultBundle!.votingFormBundle;
                  int tabsCount = 0;
                  if (votingFormBundle.headerVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }
                  if (votingFormBundle.participantVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }
                  if (votingFormBundle.footerVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }

                  if (tabsCount == 0) {
                    return Center(
                      child: Text(
                        'No field was added to the form\nfor this jury',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return DefaultTabController(
                    length: tabsCount,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            if (votingFormBundle.headerVotingFormFields.isNotEmpty)
                              Tab(text: 'Header'),
                            if (votingFormBundle.participantVotingFormFields.isNotEmpty)
                              Tab(text: 'Participants'),
                            if (votingFormBundle.footerVotingFormFields.isNotEmpty)
                              Tab(text: 'Footer'),
                          ],
                        ),
                        SizedBox(height: 24),
                        Expanded(
                          child: TabBarView(children: [
                            if (votingFormBundle.headerVotingFormFields.isNotEmpty)
                              _buildHeaderTab(context, state),
                            if (votingFormBundle.participantVotingFormFields.isNotEmpty)
                              _buildParticipantsTab(context, state),
                            if (votingFormBundle.footerVotingFormFields.isNotEmpty)
                              _buildFooterTab(context, state),
                          ]),
                        ),
                      ],
                    ),
                  );

                  // return ListView(
                  //   children: [
                  //     if (votingSessionJurors.where((e) => e.hasSubmitted).isNotEmpty)
                  //       Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text('Jurors that submitted'),
                  //           ...votingSessionJurors
                  //               .where((e) => e.hasSubmitted)
                  //               .map((votingSessionJuror) {
                  //             return ListTile(
                  //               onTap: () {},
                  //               title: Text(votingSessionJuror.jurorFullName),
                  //             );
                  //           }),
                  //         ],
                  //       ),
                  //     if (votingSessionJurors.where((e) => !e.hasSubmitted).isNotEmpty)
                  //       Column(
                  //         mainAxisSize: MainAxisSize.min,
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text("Jurors that didn't submit"),
                  //           ...votingSessionJurors
                  //               .where((e) => !e.hasSubmitted)
                  //               .map((votingSessionJuror) {
                  //             return Card(
                  //               elevation: 0,
                  //               child: ListTile(
                  //                 onTap: () {},
                  //                 title: Text(votingSessionJuror.jurorFullName),
                  //               ),
                  //             );
                  //           }),
                  //         ],
                  //       ),
                  //   ],
                  // );
                  // switch (state.status) {
                  //   case BlocStatus.initial:
                  //     return VoidWidget();
                  //   case BlocStatus.loading:
                  //     if (!state.isInitialized) {
                  //       return VoidWidget();
                  //     } else {
                  //       continue successCase;
                  //     }
                  //   case BlocStatus.failure:
                  //     if (!state.isInitialized) {
                  //       return RefreshIndicator.adaptive(
                  //         onRefresh: () async => context
                  //             .read<OrganizerJurorVotingResultsPageBloc>()
                  //             .add(OrganizerJurorVotingResultsPageFetch(
                  //                 votingSessionJurorId: votingSessionJurorId)),
                  //         child: ListViewWithCentralLabel(
                  //           label: Labels.anErrorOccurred,
                  //         ),
                  //       );
                  //     } else {
                  //       continue successCase;
                  //     }
                  //   successCase:
                  //   case BlocStatus.success:
                  //   // List<DataColumn> columnsHeaders = [];
                  //   // List<DataRow> rows = [];
                  //   //
                  //   // if (participantsVotingsPerJurorMap.isEmpty) {
                  //   //   return Center(
                  //   //     child: Text('No vote submitted'),
                  //   //   );
                  //   // }
                  //   //
                  //   // //* Table headers
                  //   // if (chosenVotingSessionParticipation != null) {
                  //   //   columnsHeaders = <DataColumn>[
                  //   //     DataColumn(label: VoidWidget()),
                  //   //     for (var field in votingFormFields)
                  //   //       DataColumn(
                  //   //         columnWidth: FixedColumnWidth(200),
                  //   //         label: Column(
                  //   //           mainAxisSize: MainAxisSize.min,
                  //   //           children: [
                  //   //             Text(
                  //   //               chosenVotingSessionParticipation!.participantFullName,
                  //   //               style: Theme.of(context)
                  //   //                   .textTheme
                  //   //                   .titleMedium
                  //   //                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //             ),
                  //   //             Text(
                  //   //               field.name,
                  //   //               style: Theme.of(context).textTheme.labelLarge,
                  //   //             ),
                  //   //           ],
                  //   //         ),
                  //   //       ),
                  //   //   ];
                  //   // } else {
                  //   //   columnsHeaders = <DataColumn>[
                  //   //     DataColumn(label: VoidWidget()),
                  //   //     for (var participationBundle in participationsBundles)
                  //   //       for (var field in votingFormFields)
                  //   //         DataColumn(
                  //   //           columnWidth: FixedColumnWidth(200),
                  //   //           label: Column(
                  //   //             mainAxisSize: MainAxisSize.min,
                  //   //             children: [
                  //   //               Text(
                  //   //                 participationBundle.participantFullName,
                  //   //                 style: Theme.of(context)
                  //   //                     .textTheme
                  //   //                     .titleMedium
                  //   //                     ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //               ),
                  //   //               Text(
                  //   //                 field.name,
                  //   //                 style: Theme.of(context).textTheme.labelLarge,
                  //   //               ),
                  //   //             ],
                  //   //           ),
                  //   //         ),
                  //   //   ];
                  //   // }
                  //   //
                  //   // //* Table rows
                  //   // if (chosenVotingSessionJuration == null &&
                  //   //     chosenVotingSessionParticipation == null) {
                  //   //   rows.clear();
                  //   //   for (var jurationBundle in votingSessionJurors) {
                  //   //     rows.add(
                  //   //       DataRow(
                  //   //         cells: [
                  //   //           DataCell(
                  //   //             Text(
                  //   //               jurationBundle.jurorFullName,
                  //   //               style: Theme.of(context)
                  //   //                   .textTheme
                  //   //                   .titleMedium
                  //   //                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //             ),
                  //   //           ),
                  //   //           for (var participationBundle in participationsBundles)
                  //   //             for (int i = 0; i < votingFormFields.length; i++)
                  //   //               DataCell(
                  //   //                 Text(
                  //   //                   (participantsVotingsPerJurorMap[jurationBundle]![
                  //   //                               participationBundle] !=
                  //   //                           null)
                  //   //                       ? participantsVotingsPerJurorMap[jurationBundle]![
                  //   //                               participationBundle]![i]
                  //   //                           .jurorVote
                  //   //                           .value
                  //   //                           .toString()
                  //   //                       : 'Excluded',
                  //   //                 ),
                  //   //               ),
                  //   //         ],
                  //   //       ),
                  //   //     );
                  //   //   }
                  //   // }
                  //   //
                  //   // if (chosenVotingSessionJuration != null &&
                  //   //     chosenVotingSessionParticipation != null) {
                  //   //   rows.clear();
                  //   //   rows.add(
                  //   //     DataRow(
                  //   //       cells: [
                  //   //         DataCell(
                  //   //           Text(
                  //   //             chosenVotingSessionJuration!.jurorFullName,
                  //   //             style: Theme.of(context)
                  //   //                 .textTheme
                  //   //                 .titleMedium
                  //   //                 ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //           ),
                  //   //         ),
                  //   //         for (int i = 0; i < votingFormFields.length; i++)
                  //   //           DataCell(
                  //   //             Text(
                  //   //               (participantsVotingsPerJurorMap[chosenVotingSessionJuration!]![
                  //   //                           chosenVotingSessionParticipation!] !=
                  //   //                       null)
                  //   //                   ? participantsVotingsPerJurorMap[
                  //   //                               chosenVotingSessionJuration!]![
                  //   //                           chosenVotingSessionParticipation!]![i]
                  //   //                       .jurorVote
                  //   //                       .value
                  //   //                       .toString()
                  //   //                   : 'Excluded',
                  //   //             ),
                  //   //           ),
                  //   //       ],
                  //   //     ),
                  //   //   );
                  //   // }
                  //   //
                  //   // if (chosenVotingSessionJuration != null &&
                  //   //     chosenVotingSessionParticipation == null) {
                  //   //   rows.clear();
                  //   //   rows.add(
                  //   //     DataRow(
                  //   //       cells: [
                  //   //         DataCell(
                  //   //           Text(
                  //   //             chosenVotingSessionJuration!.jurorFullName,
                  //   //             style: Theme.of(context)
                  //   //                 .textTheme
                  //   //                 .titleMedium
                  //   //                 ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //           ),
                  //   //         ),
                  //   //         for (var participationBundle in participationsBundles)
                  //   //           for (int i = 0; i < votingFormFields.length; i++)
                  //   //             DataCell(
                  //   //               Text(
                  //   //                 (participantsVotingsPerJurorMap[
                  //   //                                 chosenVotingSessionJuration!]![
                  //   //                             participationBundle] !=
                  //   //                         null)
                  //   //                     ? participantsVotingsPerJurorMap[
                  //   //                                 chosenVotingSessionJuration!]![
                  //   //                             participationBundle]![i]
                  //   //                         .jurorVote
                  //   //                         .value
                  //   //                         .toString()
                  //   //                     : 'Excluded',
                  //   //               ),
                  //   //             ),
                  //   //       ],
                  //   //     ),
                  //   //   );
                  //   // }
                  //   //
                  //   // if (chosenVotingSessionJuration == null &&
                  //   //     chosenVotingSessionParticipation != null) {
                  //   //   rows.clear();
                  //   //   for (var jurationBundle in votingSessionJurors) {
                  //   //     rows.add(
                  //   //       DataRow(
                  //   //         cells: [
                  //   //           DataCell(
                  //   //             Text(
                  //   //               jurationBundle.jurorFullName,
                  //   //               style: Theme.of(context)
                  //   //                   .textTheme
                  //   //                   .titleMedium
                  //   //                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  //   //             ),
                  //   //           ),
                  //   //           for (int i = 0; i < votingFormFields.length; i++)
                  //   //             DataCell(
                  //   //               Text(
                  //   //                 (participantsVotingsPerJurorMap[jurationBundle]![
                  //   //                             chosenVotingSessionParticipation!] !=
                  //   //                         null)
                  //   //                     ? participantsVotingsPerJurorMap[jurationBundle]![
                  //   //                             chosenVotingSessionParticipation!]![i]
                  //   //                         .jurorVote
                  //   //                         .value
                  //   //                         .toString()
                  //   //                     : 'Excluded',
                  //   //               ),
                  //   //             ),
                  //   //         ],
                  //   //       ),
                  //   //     );
                  //   //   }
                  //   // }
                  //   //
                  //   // return ListView(
                  //   //   children: [
                  //   //     SizedBox(height: 16),
                  //   //     DropdownMenu(
                  //   //       label: Text('Juror'),
                  //   //       enableSearch: false,
                  //   //       maxLines: 1,
                  //   //       textStyle: Theme.of(context).textTheme.labelLarge,
                  //   //       onSelected: (value) {
                  //   //         setState(() {
                  //   //           chosenVotingSessionJuration = value;
                  //   //         });
                  //   //       },
                  //   //       dropdownMenuEntries: [
                  //   //         DropdownMenuEntry(
                  //   //           value: null,
                  //   //           label: 'All',
                  //   //         ),
                  //   //         for (var jurationBundle in votingSessionJurors)
                  //   //           DropdownMenuEntry(
                  //   //             value: jurationBundle,
                  //   //             label: jurationBundle.jurorFullName,
                  //   //           ),
                  //   //       ],
                  //   //     ),
                  //   //     SizedBox(height: 20),
                  //   //     DropdownMenu(
                  //   //       label: Text('Participant'),
                  //   //       enableSearch: false,
                  //   //       maxLines: 1,
                  //   //       textStyle: Theme.of(context).textTheme.labelLarge,
                  //   //       onSelected: (value) {
                  //   //         setState(() {
                  //   //           chosenVotingSessionParticipation = value;
                  //   //         });
                  //   //       },
                  //   //       dropdownMenuEntries: [
                  //   //         DropdownMenuEntry(
                  //   //           value: null,
                  //   //           label: 'All',
                  //   //         ),
                  //   //         for (var participationBundle in participationsBundles)
                  //   //           DropdownMenuEntry(
                  //   //             value: participationBundle,
                  //   //             label: participationBundle.participantFullName,
                  //   //           ),
                  //   //       ],
                  //   //     ),
                  //   //     SizedBox(height: 24),
                  //   //     SingleChildScrollView(
                  //   //       scrollDirection: Axis.horizontal,
                  //   //       child: DataTable(
                  //   //         headingRowHeight: 80,
                  //   //         border:
                  //   //             TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
                  //   //         dataRowMaxHeight: double.infinity,
                  //   //         columns: columnsHeaders,
                  //   //         rows: rows,
                  //   //       ),
                  //   //     ),
                  //   //     SizedBox(height: 72),
                  //   //   ],
                  //   // );
                  // }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final headerValues = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .headerVotingFormSubmissionValuesBundles;
    final headerFields = state.votingSessionJurorResultBundle!.votingFormBundle.headerVotingFormFields;
    return ListView.builder(
      itemCount: headerFields.length,
      itemBuilder: (context, index) {
        final headerField = headerFields[index];
        final headerValue = headerValues.where((e) => e.votingFormField == headerField).singleOrNull;
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${headerField.question} ${(headerField.isRequired) ? '*' : ''}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              Text((headerValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                  ? headerValue!.votingFormSubmissionValue.value
                  : 'No answer')
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final footerValues = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .footerVotingFormSubmissionValuesBundles;
    final footerFields = state.votingSessionJurorResultBundle!.votingFormBundle.footerVotingFormFields;
    return ListView.builder(
      itemCount: footerFields.length,
      itemBuilder: (context, index) {
        final footerField = footerFields[index];
        final footerValue = footerValues.where((e) => e.votingFormField == footerField).singleOrNull;
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${footerField.question} ${(footerField.isRequired) ? '*' : ''}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              Text((footerValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                  ? footerValue!.votingFormSubmissionValue.value
                  : 'No answer')
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantsTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final votingSessionParticipants =
        state.votingSessionJurorResultBundle!.votingSessionParticipants;
    final participantsValuesMap = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .participantVotingFormSubmissionValuesBundles;
    final excludedVotingSessionParticipantsIds =
        state.votingSessionJurorResultBundle!.excludedVotingSessionParticipantsIds;
    List<VotingFormSubmissionValueBundle>? participantValues =
        participantsValuesMap[chosenVotingSessionParticipant];
    final participantFields = state.votingSessionJurorResultBundle!.votingFormBundle.participantVotingFormFields;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        DropdownMenu(
          label: Text('Participant'),
          onSelected: (value) {
            setState(() {
              chosenVotingSessionParticipant = value!;
            });
          },
          initialSelection: chosenVotingSessionParticipant,
          dropdownMenuEntries: [
            ...votingSessionParticipants.map((votingSessionParticipant) {
              return DropdownMenuEntry(
                value: votingSessionParticipant,
                label: votingSessionParticipant.participantFullName,
              );
            }),
          ],
        ),
        SizedBox(height: 16),
        if (chosenVotingSessionParticipant == null)
          Text('Select a participant')
        else if (excludedVotingSessionParticipantsIds.contains(chosenVotingSessionParticipant?.id!))
          Text('Excluded from voting this participant')
        else
          ...participantFields.map((participantField) {
            final participantValue = participantValues?.where((e) => e.votingFormField == participantField).singleOrNull;
            return Padding(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${participantField.question} ${(participantField.isRequired) ? '*' : ''}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text((participantValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                      ? participantValue!.votingFormSubmissionValue.value
                      : 'No answer')
                ],
              ),
            );
          }),
      ],
    );
  }
}
