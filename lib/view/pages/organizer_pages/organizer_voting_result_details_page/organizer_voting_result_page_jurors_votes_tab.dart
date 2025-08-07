// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/model/database/bundles/juration_bundle.dart';
// import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
// import 'package:swift_contest/utils/labels/labels.dart';
// import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
// import 'package:swift_contest/view/widgets/overlay_loader.dart';
// import 'package:swift_contest/view/widgets/void_widget.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_details_page_bloc/organizer_voting_result_details_page_bloc.dart';
// import 'package:swift_contest/viewmodel/types/bloc_status.dart';
//
// class OrganizerVotingResultPageJurorsVotesTab extends StatefulWidget {
//   final String votingSessionId;
//
//   const OrganizerVotingResultPageJurorsVotesTab({required this.votingSessionId, super.key});
//
//   @override
//   State<OrganizerVotingResultPageJurorsVotesTab> createState() =>
//       _OrganizerVotingResultPageJurorsVotesTabState();
// }
//
// class _OrganizerVotingResultPageJurorsVotesTabState
//     extends State<OrganizerVotingResultPageJurorsVotesTab> {
//   late final String votingSessionId;
//   JurationBundle? chosenJurationBundle;
//   ParticipationBundle? chosenParticipationBundle;
//
//   @override
//   void initState() {
//     super.initState();
//     votingSessionId = widget.votingSessionId;
//   }
//
//   @override
//   void dispose() {
//     context.hideLoader();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<OrganizerVotingResultDetailsPageBloc, OrganizerVotingResultDetailsPageState>(
//       builder: (context, state) {
//         return Scaffold(
//           body: Builder(
//             builder: (context) {
//               switch (state.status) {
//                 case BlocStatus.initial:
//                   return VoidWidget();
//                 case BlocStatus.loading:
//                   if (!state.isInitialized) {
//                     return VoidWidget();
//                   } else {
//                     continue successCase;
//                   }
//                 case BlocStatus.failure:
//                   if (!state.isInitialized) {
//                     return RefreshIndicator.adaptive(
//                       onRefresh: () async {
//                         context
//                             .read<OrganizerVotingResultDetailsPageBloc>()
//                             .add(OrganizerVotingResultDetailsPageFetch(
//                               votingSessionId: votingSessionId,
//                             ));
//                       },
//                       child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
//                     );
//                   } else {
//                     continue successCase;
//                   }
//                 successCase:
//                 case BlocStatus.success:
//                   final votingSessionResultBundle = state.votingSessionResultBundle!;
//                   final votingFormFields =
//                       votingSessionResultBundle.votingFormBundle.votingFormFields;
//                   final List<JurationBundle> jurationsBundles = state
//                       .votingSessionResultBundle!.participantsVotingsPerJurorMap.entries
//                       .map((e) => e.key)
//                       .toList(growable: false);
//                   final List<ParticipationBundle> participationsBundles = state
//                       .votingSessionResultBundle!.jurorsVotingsPerParticipantMap.entries
//                       .map((e) => e.key)
//                       .toList(growable: false);
//                   final participantsVotingsPerJurorMap =
//                       state.votingSessionResultBundle!.participantsVotingsPerJurorMap;
//                   List<DataColumn> columnsHeaders = [];
//                   List<DataRow> rows = [];
//
//                   if (participantsVotingsPerJurorMap.isEmpty) {
//                     return ListViewWithCentralLabel(label: 'No vote submitted');
//                   }
//
//                   //* Table headers
//                   if (chosenParticipationBundle != null) {
//                     columnsHeaders = <DataColumn>[
//                       DataColumn(label: VoidWidget()),
//                       for (var field in votingFormFields)
//                         DataColumn(
//                           label: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Text(
//                                 chosenParticipationBundle!.participant.fullName,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                               ),
//                               Text(
//                                 field.name,
//                                 style: Theme.of(context).textTheme.labelLarge,
//                               ),
//                             ],
//                           ),
//                         ),
//                     ];
//                   } else {
//                     columnsHeaders = <DataColumn>[
//                       DataColumn(label: VoidWidget()),
//                       for (var participationBundle in participationsBundles)
//                         for (var field in votingFormFields)
//                           DataColumn(
//                             label: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   participationBundle.participant.fullName,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .titleMedium
//                                       ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                                 ),
//                                 Text(
//                                   field.name,
//                                   style: Theme.of(context).textTheme.labelLarge,
//                                 ),
//                               ],
//                             ),
//                           ),
//                     ];
//                   }
//
//                   //* Table rows
//                   if (chosenJurationBundle == null && chosenParticipationBundle == null) {
//                     rows.clear();
//                     for (var jurationBundle in jurationsBundles) {
//                       rows.add(
//                         DataRow(
//                           cells: [
//                             DataCell(
//                               Text(
//                                 jurationBundle.juror.fullName,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                               ),
//                             ),
//                             for (var participationBundle in participationsBundles)
//                               for (int i = 0; i < votingFormFields.length; i++)
//                                 DataCell(
//                                   Text(
//                                     (participantsVotingsPerJurorMap[jurationBundle]![
//                                                 participationBundle] !=
//                                             null)
//                                         ? participantsVotingsPerJurorMap[jurationBundle]![
//                                                 participationBundle]![i]
//                                             .jurorVote
//                                             .value
//                                             .toString()
//                                         : 'Excluded',
//                                   ),
//                                 ),
//                           ],
//                         ),
//                       );
//                     }
//                   }
//
//                   if (chosenJurationBundle != null && chosenParticipationBundle != null) {
//                     rows.clear();
//                     rows.add(
//                       DataRow(
//                         cells: [
//                           DataCell(
//                             Text(
//                               chosenJurationBundle!.juror.fullName,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium
//                                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                             ),
//                           ),
//                           for (int i = 0; i < votingFormFields.length; i++)
//                             DataCell(
//                               Text(
//                                 (participantsVotingsPerJurorMap[chosenJurationBundle!]![
//                                             chosenParticipationBundle!] !=
//                                         null)
//                                     ? participantsVotingsPerJurorMap[chosenJurationBundle!]![
//                                             chosenParticipationBundle!]![i]
//                                         .jurorVote
//                                         .value
//                                         .toString()
//                                     : 'Excluded',
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   if (chosenJurationBundle != null && chosenParticipationBundle == null) {
//                     rows.clear();
//                     rows.add(
//                       DataRow(
//                         cells: [
//                           DataCell(
//                             Text(
//                               chosenJurationBundle!.juror.fullName,
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium
//                                   ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                             ),
//                           ),
//                           for (var participationBundle in participationsBundles)
//                             for (int i = 0; i < votingFormFields.length; i++)
//                               DataCell(
//                                 Text(
//                                   (participantsVotingsPerJurorMap[chosenJurationBundle!]![
//                                               participationBundle] !=
//                                           null)
//                                       ? participantsVotingsPerJurorMap[chosenJurationBundle!]![
//                                               participationBundle]![i]
//                                           .jurorVote
//                                           .value
//                                           .toString()
//                                       : 'Excluded',
//                                 ),
//                               ),
//                         ],
//                       ),
//                     );
//                   }
//
//                   if (chosenJurationBundle == null && chosenParticipationBundle != null) {
//                     rows.clear();
//                     for (var jurationBundle in jurationsBundles) {
//                       rows.add(
//                         DataRow(
//                           cells: [
//                             DataCell(
//                               Text(
//                                 jurationBundle.juror.fullName,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(color: Theme.of(context).colorScheme.primary),
//                               ),
//                             ),
//                             for (int i = 0; i < votingFormFields.length; i++)
//                               DataCell(
//                                 Text(
//                                   (participantsVotingsPerJurorMap[jurationBundle]![
//                                               chosenParticipationBundle!] !=
//                                           null)
//                                       ? participantsVotingsPerJurorMap[jurationBundle]![
//                                               chosenParticipationBundle!]![i]
//                                           .jurorVote
//                                           .value
//                                           .toString()
//                                       : 'Excluded',
//                                 ),
//                               ),
//                           ],
//                         ),
//                       );
//                     }
//                   }
//
//                   return ListView(
//                     children: [
//                       SizedBox(height: 16),
//                       DropdownMenu(
//                         label: Text('Juror'),
//                         enableSearch: false,
//                         maxLines: 1,
//                         textStyle: Theme.of(context).textTheme.labelLarge,
//                         onSelected: (value) {
//                           setState(() {
//                             chosenJurationBundle = value;
//                             columnsHeaders = columnsHeaders;
//                             rows = rows;
//                           });
//                         },
//                         dropdownMenuEntries: [
//                           DropdownMenuEntry(
//                             value: null,
//                             label: 'All',
//                           ),
//                           for (var jurationBundle in jurationsBundles)
//                             DropdownMenuEntry(
//                               value: jurationBundle,
//                               label: jurationBundle.juror.fullName,
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 20),
//                       DropdownMenu(
//                         label: Text('Participant'),
//                         enableSearch: false,
//                         maxLines: 1,
//                         textStyle: Theme.of(context).textTheme.labelLarge,
//                         onSelected: (value) {
//                           setState(() {
//                             chosenParticipationBundle = value;
//                             columnsHeaders = columnsHeaders;
//                             rows = rows;
//                           });
//                         },
//                         dropdownMenuEntries: [
//                           DropdownMenuEntry(
//                             value: null,
//                             label: 'All',
//                           ),
//                           for (var participationBundle in participationsBundles)
//                             DropdownMenuEntry(
//                               value: participationBundle,
//                               label: participationBundle.participant.fullName,
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 24),
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: DataTable(
//                           columns: columnsHeaders,
//                           rows: rows,
//                         ),
//                       ),
//                       SizedBox(height: 72),
//                     ],
//                   );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
// }
