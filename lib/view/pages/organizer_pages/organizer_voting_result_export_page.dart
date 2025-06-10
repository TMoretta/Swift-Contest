import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/model/bundles/organizer_voting_session_bundle.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/juror_vote.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_export_page_bloc/organizer_voting_result_export_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class OrganizerVotingResultExportPage extends StatefulWidget {
  final OrganizerVotingSessionBundle votingSessionBundle;

  const OrganizerVotingResultExportPage({required this.votingSessionBundle, super.key});

  @override
  State<OrganizerVotingResultExportPage> createState() => _OrganizerVotingResultExportPageState();
}

class _OrganizerVotingResultExportPageState extends State<OrganizerVotingResultExportPage> {
  late OrganizerVotingSessionBundle votingSessionBundle;
  List<Participant> selectedParticipants = [];
  List<Juror> selectedJurors = [];
  List<VotingFormField> selectedFields = [];

  @override
  void initState() {
    super.initState();
    votingSessionBundle = widget.votingSessionBundle;
    context.read<OrganizerVotingResultExportPageBloc>().add(
        OrganizerVotingResultExportPageGetResultInfo(votingSessionBundle: votingSessionBundle));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Export'),
      body: BlocConsumer<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
        listener: (context, state) {
          if (state.status.isFailure && state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return Loader();
            case BlocStatus.failure:
              if (state.participantsVotingsPerJurorMap == null) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    context.read<OrganizerVotingResultExportPageBloc>().add(
                        OrganizerVotingResultExportPageGetResultInfo(
                            votingSessionBundle: votingSessionBundle));
                  },
                  child: ListView(physics: AlwaysScrollableScrollPhysics()),
                );
              }
              continue successCase;
            successCase:
            case BlocStatus.success:
              final participants = votingSessionBundle.votingSessionParticipationsBundles
                  .map((e) => e.participationBundle.participant)
                  .toList(growable: false);
              final jurors = state.participantsVotingsPerJurorMap!.entries.map((e) => e.key.juror).toList(growable: false);
              final votingFormFields = votingSessionBundle.votingFormBundle.votingFormFields;
              return ListView(
                children: [
                  // Selezione partecipanti
                  MultiSelectDialogField<Participant>(
                    items: participants
                        .map((e) => MultiSelectItem(e, e.fullName))
                        .toList(growable: false),
                    title: Text('Participants'),
                    buttonText: Text('Select participants'),
                    listType: MultiSelectListType.CHIP,
                    initialValue: selectedParticipants,
                    onConfirm: (values) {
                      setState(() {
                        selectedParticipants = values;
                      });
                    },
                  ),

                  SizedBox(height: 12),

                  // Selezione giurati
                  MultiSelectDialogField<Juror>(
                    items: jurors
                        .map((e) => MultiSelectItem(e, e.fullName))
                        .toList(growable: false),
                    title: Text('Jurors'),
                    buttonText: Text('Select jurors'),
                    listType: MultiSelectListType.CHIP,
                    initialValue: selectedJurors,
                    onConfirm: (values) {
                      setState(() {
                        selectedJurors = values;
                      });
                    },
                  ),

                  SizedBox(height: 12),

                  // Selezione campi del form
                  MultiSelectDialogField<VotingFormField>(
                    items: votingFormFields.map((f) => MultiSelectItem(f, f.name)).toList(),
                    title: Text('Fields'),
                    buttonText: Text('Select fields'),
                    listType: MultiSelectListType.LIST,
                    initialValue: selectedFields,
                    onConfirm: (values) {
                      setState(() {
                        selectedFields = values;
                      });
                    },
                  ),
                ],
              );
          }
        },
      ),
      floatingActionButton:
          BlocConsumer<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
        listener: (context, state) {
          if (state.status.isFailure && state.message != null) {
            showSnackBar(context: context, text: state.message!);
          }
        },
        builder: (context, state) {
          switch (state.status) {
            case BlocStatus.initial:
              return SizedBox.shrink();
            case BlocStatus.loading:
              return SizedBox.shrink();
            case BlocStatus.failure:
              if (state.participantsVotingsPerJurorMap == null) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    context.read<OrganizerVotingResultExportPageBloc>().add(
                        OrganizerVotingResultExportPageGetResultInfo(
                            votingSessionBundle: votingSessionBundle));
                  },
                  child: ListView(physics: AlwaysScrollableScrollPhysics()),
                );
              }
              continue successCase;
            successCase:
            case BlocStatus.success:
              final participantsVotingsPerJurorMap = state.participantsVotingsPerJurorMap!;
              final jurorsVotingsPerParticipantMap = state.jurorsVotingsPerParticipantMap!;
              return FloatingActionButton(
                onPressed: () async {
                  if (selectedFields.isEmpty ||
                      selectedJurors.isEmpty ||
                      selectedParticipants.isEmpty) {
                    showSnackBar(
                        context: context,
                        text: 'Select at least one field, one juror and one participant');
                    return;
                  }

                  if (!await requestStoragePermission()) {
                    if (context.mounted) {
                      showSnackBar(context: context, text: 'Permission denied');
                    }
                    return;
                  }

                  final Workbook workbook = Workbook();
                  final Worksheet sheet = workbook.worksheets[0];
                  sheet.name = 'Results';

                  // 3) Costruisci i dati di header
                  // Riga 1: merged cell per i giurati
                  int col = 2; // colonna 1 è "Partecipante"
                  for (var juror in selectedJurors) {
                    int start = col, end = col + selectedFields.length - 1;
                    sheet.getRangeByIndex(1, start, 1, end).merge();
                    sheet.getRangeByIndex(1, start).setText(juror.fullName);
                    sheet.getRangeByIndex(1, start).cellStyle.hAlign = HAlignType.center;
                    col = end + 1;
                  }
                  sheet.getRangeByIndex(1, 1).setText('Participant');
                  sheet.getRangeByIndex(1, 1).cellStyle.hAlign = HAlignType.center;

                  // Riga 2: nomi dei campi
                  col = 2;
                  for (var juror in selectedJurors) {
                    for (var field in selectedFields) {
                      sheet.getRangeByIndex(2, col).setText(field.name);
                      sheet.getRangeByIndex(2, col).cellStyle.hAlign = HAlignType.center;
                      col++;
                    }
                  }

                  // 4) Scrivi il corpo dati
                  final participants = votingSessionBundle.votingSessionParticipationsBundles
                      .map((e) => e.participationBundle.participant)
                      .toList(growable: false);
                  for (int i = 0; i < participants.length; i++) {
                    final participant = participants[i];
                    // colonna 1: nome partecipante, riga i+3
                    sheet.getRangeByIndex(i + 3, 1).setText(participant.fullName);
                    col = 2;
                    for (var juror in selectedJurors) {
                      final voteList = jurorsVotingsPerParticipantMap[participant]![juror];
                      if (voteList == null) {
                        // riempi con "Excluded"
                        for (int k = 0; k < selectedFields.length; k++) {
                          sheet.getRangeByIndex(i + 3, col).setText('Excluded');
                          col++;
                        }
                      } else {
                        for (int k = 0; k < selectedFields.length; k++) {
                          sheet.getRangeByIndex(i + 3, col).setText(voteList[k].jurorVote.value.toString());
                          col++;
                        }
                      }
                    }
                  }

                  var path = await ExternalPath.getExternalStoragePublicDirectory(
                      ExternalPath.DIRECTORY_DOWNLOAD);
                  final now = DateTime.now();
                  final filename =
                      'voting_results_${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}.xlsx';
                  final fileBytes = workbook.saveAsStream();
                  workbook.dispose();

                  final file = File('$path/$filename');
                  await file.writeAsBytes(fileBytes, flush: true);

                  //*--------------------
                  // final headerRow1 = <String>['Participant/Juror'];
                  // for (var juror in selectedJurors) {
                  //   headerRow1.add(juror.fullName);
                  //   for (int i = 0; i < selectedFields.length - 1; i++) {
                  //     headerRow1.add('.'); // celle vuote per simulare colspan
                  //   }
                  // }
                  //
                  // final headerRow2 = <String>[''];
                  // for (var juror in selectedJurors) {
                  //   for (var field in selectedFields) {
                  //     headerRow2.add(field.name);
                  //   }
                  // }
                  //
                  // final dataRows = <List<String>>[];
                  // for (var participant in selectedParticipants) {
                  //   final row = <String>[participant.fullName];
                  //   for (var juror in selectedJurors) {
                  //     final voteList = votesPerParticipantMap[participant]?[juror];
                  //     if (voteList == null) {
                  //       // parte non votata o esclusa
                  //       row.addAll(List.filled(selectedFields.length, 'Excluded'));
                  //     } else {
                  //       // assumiamo che voteList sia già ordinato secondo selectedFields
                  //       row.addAll(voteList.map((v) => v.value));
                  //     }
                  //   }
                  //   dataRows.add(row);
                  // }
                  //
                  // final allRows = [headerRow1, headerRow2, ...dataRows];
                  // final csvData = const ListToCsvConverter().convert(allRows);
                  //
                  //
                  // var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
                  // final now = DateTime.now();
                  // final filename = 'voting_results_${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}.csv';
                  //
                  // final file = File('$path/$filename');
                  // await file.writeAsString(csvData);
                },
                child: Icon(Icons.download),
              );
          }
        },
      ),
    );
  }
}

Future<bool> requestStoragePermission() async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  if (build.version.sdkInt >= 11) {
    var request = await Permission.manageExternalStorage.request();
    if (request.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await Permission.storage.isGranted) {
      return true;
    } else {
      var request = await Permission.storage.request();
      if (request.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: CustomAppBar(title: 'Export'),
//     body: ListView(
//       children: [
//         // Selezione partecipanti
//         MultiSelectDialogField<Participant>(
//           items: participants.map((p) => MultiSelectItem(p, p.fullName)).toList(),
//           title: Text('Participants'),
//           buttonText: Text('Select participants'),
//           listType: MultiSelectListType.CHIP,
//           initialValue: selectedParticipants,
//           onConfirm: (values) {
//             setState(() {
//               selectedParticipants = values;
//             });
//           },
//         ),
//
//         SizedBox(height: 12),
//
//         // Selezione giurati
//         MultiSelectDialogField<Juror>(
//           items: jurorsThatSubmitted.map((j) => MultiSelectItem(j, j.fullName)).toList(),
//           title: Text('Jurors'),
//           buttonText: Text('Select jurors'),
//           listType: MultiSelectListType.CHIP,
//           initialValue: selectedJurors,
//           onConfirm: (values) {
//             setState(() {
//               selectedJurors = values;
//             });
//           },
//         ),
//
//         SizedBox(height: 12),
//
//         // Selezione campi del form
//         MultiSelectDialogField<VotingFormField>(
//           items: votingFormFields.map((f) => MultiSelectItem(f, f.name)).toList(),
//           title: Text('Fields'),
//           buttonText: Text('Select fields'),
//           listType: MultiSelectListType.LIST,
//           initialValue: selectedFields,
//           onConfirm: (values) {
//             setState(() {
//               selectedFields = values;
//             });
//           },
//         ),
//       ],
//     ),
//     floatingActionButton: FloatingActionButton(
//       onPressed: () async {
//         if (selectedFields.isEmpty || selectedJurors.isEmpty || selectedParticipants.isEmpty) {
//           showSnackBar(
//               context: context, text: 'Select at least one field, one juror and one participant');
//           return;
//         }
//
//         if (!await requestStoragePermission()) {
//           if (context.mounted) {
//             showSnackBar(context: context, text: 'Permission denied');
//           }
//           return;
//         }
//
//         final Workbook workbook = Workbook();
//         final Worksheet sheet = workbook.worksheets[0];
//         sheet.name = 'Results';
//
//         // 3) Costruisci i dati di header
//         // Riga 1: merged cell per i giurati
//         int col = 2; // colonna 1 è "Partecipante"
//         for (var juror in selectedJurors) {
//           int start = col, end = col + selectedFields.length - 1;
//           sheet.getRangeByIndex(1, start, 1, end).merge();
//           sheet.getRangeByIndex(1, start).setText(juror.fullName);
//           sheet.getRangeByIndex(1, start).cellStyle.hAlign = HAlignType.center;
//           col = end + 1;
//         }
//         sheet.getRangeByIndex(1, 1).setText('Participant');
//         sheet.getRangeByIndex(1, 1).cellStyle.hAlign = HAlignType.center;
//
//         // Riga 2: nomi dei campi
//         col = 2;
//         for (var juror in selectedJurors) {
//           for (var field in selectedFields) {
//             sheet.getRangeByIndex(2, col).setText(field.name);
//             sheet.getRangeByIndex(2, col).cellStyle.hAlign = HAlignType.center;
//             col++;
//           }
//         }
//
//         // 4) Scrivi il corpo dati
//         for (int i = 0; i < participants.length; i++) {
//           final participant = participants[i];
//           // colonna 1: nome partecipante, riga i+3
//           sheet.getRangeByIndex(i + 3, 1).setText(participant.fullName);
//           col = 2;
//           for (var juror in selectedJurors) {
//             final voteList = jurorVotesPerParticipantMap[participant]?[juror];
//             if (voteList == null) {
//               // riempi con "Excluded"
//               for (int k = 0; k < selectedFields.length; k++) {
//                 sheet.getRangeByIndex(i + 3, col).setText('Excluded');
//                 col++;
//               }
//             } else {
//               for (int k = 0; k < selectedFields.length; k++) {
//                 sheet.getRangeByIndex(i + 3, col).setText(voteList[k].value);
//                 col++;
//               }
//             }
//           }
//         }
//
//         var path =
//             await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
//         final now = DateTime.now();
//         final filename =
//             'voting_results_${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}.xlsx';
//         final fileBytes = workbook.saveAsStream();
//         workbook.dispose();
//
//         final file = File('$path/$filename');
//         await file.writeAsBytes(fileBytes, flush: true);
//
//         //*--------------------
//         // final headerRow1 = <String>['Participant/Juror'];
//         // for (var juror in selectedJurors) {
//         //   headerRow1.add(juror.fullName);
//         //   for (int i = 0; i < selectedFields.length - 1; i++) {
//         //     headerRow1.add('.'); // celle vuote per simulare colspan
//         //   }
//         // }
//         //
//         // final headerRow2 = <String>[''];
//         // for (var juror in selectedJurors) {
//         //   for (var field in selectedFields) {
//         //     headerRow2.add(field.name);
//         //   }
//         // }
//         //
//         // final dataRows = <List<String>>[];
//         // for (var participant in selectedParticipants) {
//         //   final row = <String>[participant.fullName];
//         //   for (var juror in selectedJurors) {
//         //     final voteList = votesPerParticipantMap[participant]?[juror];
//         //     if (voteList == null) {
//         //       // parte non votata o esclusa
//         //       row.addAll(List.filled(selectedFields.length, 'Excluded'));
//         //     } else {
//         //       // assumiamo che voteList sia già ordinato secondo selectedFields
//         //       row.addAll(voteList.map((v) => v.value));
//         //     }
//         //   }
//         //   dataRows.add(row);
//         // }
//         //
//         // final allRows = [headerRow1, headerRow2, ...dataRows];
//         // final csvData = const ListToCsvConverter().convert(allRows);
//         //
//         //
//         // var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
//         // final now = DateTime.now();
//         // final filename = 'voting_results_${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}.csv';
//         //
//         // final file = File('$path/$filename');
//         // await file.writeAsString(csvData);
//       },
//       child: Icon(Icons.download),
//     ),
//   );
// }
