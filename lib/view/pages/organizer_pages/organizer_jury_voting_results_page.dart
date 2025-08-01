import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_voting_results_page_bloc/organizer_jury_voting_results_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerJuryVotingResultsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJuryId;

  const OrganizerJuryVotingResultsPage({
    @PathParam('votingSessionJuryId') required this.votingSessionJuryId,
    super.key,
  });

  @override
  State<OrganizerJuryVotingResultsPage> createState() => _OrganizerJuryVotingResultsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJuryVotingResultsPageBloc>(
      create: (context) => OrganizerJuryVotingResultsPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerJuryVotingResultsPageState extends State<OrganizerJuryVotingResultsPage> {
  late String votingSessionJuryId;
  VotingSessionJuration? chosenVotingSessionJuration;
  VotingSessionParticipant? chosenVotingSessionParticipation;
  static const double maxCellWidth = 80;

  @override
  void initState() {
    super.initState();
    votingSessionJuryId = widget.votingSessionJuryId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerJuryVotingResultsPageBloc>()
        .add(OrganizerJuryVotingResultsPageFetch(votingSessionJuryId: votingSessionJuryId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJuryVotingResultsPageBloc, OrganizerJuryVotingResultsPageState>(
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
        return Placeholder();
        // return Scaffold(
        //   appBar: CustomAppBar(
        //       title: state.votingSessionJuryResultBundle?.votingSessionJuryBundle.votingSessionJury
        //               .juryName ??
        //           ''),
        //   body: SafeArea(
        //     child: Padding(
        //       padding: EdgeInsets.only(left: 16, top: 16, right: 16),
        //       child: Builder(
        //         builder: (context) {
        //           switch (state.status) {
        //             case BlocStatus.initial:
        //               return VoidWidget();
        //             case BlocStatus.loading:
        //               if (!state.isInitialized) {
        //                 return VoidWidget();
        //               } else {
        //                 continue successCase;
        //               }
        //             case BlocStatus.failure:
        //               if (!state.isInitialized) {
        //                 return RefreshIndicator.adaptive(
        //                   onRefresh: () async => context.read<OrganizerJuryVotingResultsPageBloc>().add(
        //                       OrganizerJuryVotingResultsPageFetch(
        //                           votingSessionJuryId: votingSessionJuryId)),
        //                   child: ListViewWithCentralLabel(
        //                     label: Labels.anErrorOccurred,
        //                   ),
        //                 );
        //               } else {
        //                 continue successCase;
        //               }
        //             successCase:
        //             case BlocStatus.success:
        //               final votingSessionJuryResultBundle = state.votingSessionJuryResultBundle!;
        //               final votingFormFields =
        //                   votingSessionJuryResultBundle.votingSessionJuryBundle.votingFormBundle.votingFormFields;
        //               final List<VotingSessionJuration> votingSessionJurations = votingSessionJuryResultBundle.votingSessionJuryBundle.votingSessionJurations;
        //               final List<VotingSessionParticipation> participationsBundles = votingSessionJuryResultBundle.votingSessionParticipations;
        //               final participantsVotingsPerJurorMap =
        //                   state.votingSessionJuryResultBundle!.participantsVotingsPerJurorMap;
        //               List<DataColumn> columnsHeaders = [];
        //               List<DataRow> rows = [];
        //
        //               if (participantsVotingsPerJurorMap.isEmpty) {
        //                 return ListViewWithCentralLabel(label: 'No vote submitted');
        //               }
        //
        //               //* Table headers
        //               if (chosenVotingSessionParticipation != null) {
        //                 columnsHeaders = <DataColumn>[
        //                   DataColumn(label: VoidWidget()),
        //                   for (var field in votingFormFields)
        //                     DataColumn(
        //                       columnWidth: FixedColumnWidth(200),
        //                       label: Column(
        //                         mainAxisSize: MainAxisSize.min,
        //                         children: [
        //                           Text(
        //                             chosenVotingSessionParticipation!.participantFullName,
        //                             style: Theme.of(context)
        //                                 .textTheme
        //                                 .titleMedium
        //                                 ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                           ),
        //                           Text(
        //                             field.name,
        //                             style: Theme.of(context).textTheme.labelLarge,
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                 ];
        //               } else {
        //                 columnsHeaders = <DataColumn>[
        //                   DataColumn(label: VoidWidget()),
        //                   for (var participationBundle in participationsBundles)
        //                     for (var field in votingFormFields)
        //                       DataColumn(
        //                         columnWidth: FixedColumnWidth(200),
        //                         label: Column(
        //                           mainAxisSize: MainAxisSize.min,
        //                           children: [
        //                             Text(
        //                               participationBundle.participantFullName,
        //                               style: Theme.of(context)
        //                                   .textTheme
        //                                   .titleMedium
        //                                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                             ),
        //                             Text(
        //                               field.name,
        //                               style: Theme.of(context).textTheme.labelLarge,
        //                             ),
        //                           ],
        //                         ),
        //                       ),
        //                 ];
        //               }
        //
        //               //* Table rows
        //               if (chosenVotingSessionJuration == null && chosenVotingSessionParticipation == null) {
        //                 rows.clear();
        //                 for (var jurationBundle in votingSessionJurations) {
        //                   rows.add(
        //                     DataRow(
        //                       cells: [
        //                         DataCell(
        //                           Text(
        //                             jurationBundle.jurorFullName,
        //                             style: Theme.of(context)
        //                                 .textTheme
        //                                 .titleMedium
        //                                 ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                           ),
        //                         ),
        //                         for (var participationBundle in participationsBundles)
        //                           for (int i = 0; i < votingFormFields.length; i++)
        //                             DataCell(
        //                               Text(
        //                                 (participantsVotingsPerJurorMap[jurationBundle]![
        //                                 participationBundle] !=
        //                                     null)
        //                                     ? participantsVotingsPerJurorMap[jurationBundle]![
        //                                 participationBundle]![i]
        //                                     .jurorVote
        //                                     .value
        //                                     .toString()
        //                                     : 'Excluded',
        //                               ),
        //                             ),
        //                       ],
        //                     ),
        //                   );
        //                 }
        //               }
        //
        //               if (chosenVotingSessionJuration != null && chosenVotingSessionParticipation != null) {
        //                 rows.clear();
        //                 rows.add(
        //                   DataRow(
        //                     cells: [
        //                       DataCell(
        //                         Text(
        //                           chosenVotingSessionJuration!.jurorFullName,
        //                           style: Theme.of(context)
        //                               .textTheme
        //                               .titleMedium
        //                               ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                         ),
        //                       ),
        //                       for (int i = 0; i < votingFormFields.length; i++)
        //                         DataCell(
        //                           Text(
        //                             (participantsVotingsPerJurorMap[chosenVotingSessionJuration!]![
        //                             chosenVotingSessionParticipation!] !=
        //                                 null)
        //                                 ? participantsVotingsPerJurorMap[chosenVotingSessionJuration!]![
        //                             chosenVotingSessionParticipation!]![i]
        //                                 .jurorVote
        //                                 .value
        //                                 .toString()
        //                                 : 'Excluded',
        //                           ),
        //                         ),
        //                     ],
        //                   ),
        //                 );
        //               }
        //
        //               if (chosenVotingSessionJuration != null && chosenVotingSessionParticipation == null) {
        //                 rows.clear();
        //                 rows.add(
        //                   DataRow(
        //                     cells: [
        //                       DataCell(
        //                         Text(
        //                           chosenVotingSessionJuration!.jurorFullName,
        //                           style: Theme.of(context)
        //                               .textTheme
        //                               .titleMedium
        //                               ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                         ),
        //                       ),
        //                       for (var participationBundle in participationsBundles)
        //                         for (int i = 0; i < votingFormFields.length; i++)
        //                           DataCell(
        //                             Text(
        //                               (participantsVotingsPerJurorMap[chosenVotingSessionJuration!]![
        //                               participationBundle] !=
        //                                   null)
        //                                   ? participantsVotingsPerJurorMap[chosenVotingSessionJuration!]![
        //                               participationBundle]![i]
        //                                   .jurorVote
        //                                   .value
        //                                   .toString()
        //                                   : 'Excluded',
        //                             ),
        //                           ),
        //                     ],
        //                   ),
        //                 );
        //               }
        //
        //               if (chosenVotingSessionJuration == null && chosenVotingSessionParticipation != null) {
        //                 rows.clear();
        //                 for (var jurationBundle in votingSessionJurations) {
        //                   rows.add(
        //                     DataRow(
        //                       cells: [
        //                         DataCell(
        //                           Text(
        //                             jurationBundle.jurorFullName,
        //                             style: Theme.of(context)
        //                                 .textTheme
        //                                 .titleMedium
        //                                 ?.copyWith(color: Theme.of(context).colorScheme.primary),
        //                           ),
        //                         ),
        //                         for (int i = 0; i < votingFormFields.length; i++)
        //                           DataCell(
        //                             Text(
        //                               (participantsVotingsPerJurorMap[jurationBundle]![
        //                               chosenVotingSessionParticipation!] !=
        //                                   null)
        //                                   ? participantsVotingsPerJurorMap[jurationBundle]![
        //                               chosenVotingSessionParticipation!]![i]
        //                                   .jurorVote
        //                                   .value
        //                                   .toString()
        //                                   : 'Excluded',
        //                             ),
        //                           ),
        //                       ],
        //                     ),
        //                   );
        //                 }
        //               }
        //
        //               return ListView(
        //                 children: [
        //                   SizedBox(height: 16),
        //                   DropdownMenu(
        //                     label: Text('Juror'),
        //                     enableSearch: false,
        //                     maxLines: 1,
        //                     textStyle: Theme.of(context).textTheme.labelLarge,
        //                     onSelected: (value) {
        //                       setState(() {
        //                         chosenVotingSessionJuration = value;
        //                       });
        //                     },
        //                     dropdownMenuEntries: [
        //                       DropdownMenuEntry(
        //                         value: null,
        //                         label: 'All',
        //                       ),
        //                       for (var jurationBundle in votingSessionJurations)
        //                         DropdownMenuEntry(
        //                           value: jurationBundle,
        //                           label: jurationBundle.jurorFullName,
        //                         ),
        //                     ],
        //                   ),
        //                   SizedBox(height: 20),
        //                   DropdownMenu(
        //                     label: Text('Participant'),
        //                     enableSearch: false,
        //                     maxLines: 1,
        //                     textStyle: Theme.of(context).textTheme.labelLarge,
        //                     onSelected: (value) {
        //                       setState(() {
        //                         chosenVotingSessionParticipation = value;
        //                       });
        //                     },
        //                     dropdownMenuEntries: [
        //                       DropdownMenuEntry(
        //                         value: null,
        //                         label: 'All',
        //                       ),
        //                       for (var participationBundle in participationsBundles)
        //                         DropdownMenuEntry(
        //                           value: participationBundle,
        //                           label: participationBundle.participantFullName,
        //                         ),
        //                     ],
        //                   ),
        //                   SizedBox(height: 24),
        //                   SingleChildScrollView(
        //                     scrollDirection: Axis.horizontal,
        //                     child: DataTable(
        //                       headingRowHeight: 80,
        //                       border: TableBorder.all(color: Theme.of(context).colorScheme.onSurface),
        //                       dataRowMaxHeight: double.infinity,
        //                       columns: columnsHeaders,
        //                       rows: rows,
        //                     ),
        //                   ),
        //                   SizedBox(height: 72),
        //                 ],
        //               );
        //           }
        //         },
        //       ),
        //     ),
        //   ),
        // );
      },
    );
  }
}


