import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swift_contest/model/data_models/profile.dart';
import 'package:swift_contest/model/data_models/vote.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/model/data_models/voting_session.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class OrganizerVotingResultsExportPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const OrganizerVotingResultsExportPage({required this.data, super.key});

  @override
  State<OrganizerVotingResultsExportPage> createState() =>
      _OrganizerVotingResultsExportPageState();
}

class _OrganizerVotingResultsExportPageState
    extends State<OrganizerVotingResultsExportPage> {
  late VotingSession votingSession;
  late List<Participant> participants;
  late List<Juror> jurorsThatSubmitted;
  late List<Juror> jurorsThatNotSubmitted;
  late List<VotingFormField> votingFormFields;
  late Map<Juror, Map<Participant, List<Vote>?>> votesPerJurorMap;
  late Map<Participant, Map<Juror, List<Vote>?>> votesPerParticipantMap;
  late Map<Profile, List<Profile>> participantsExclusionsPerJurorMap;

  List<Participant> selectedParticipants = [];
  List<Juror> selectedJurors = [];
  List<VotingFormField> selectedFields = [];

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> data = widget.data;

    votingSession = VotingSession.fromJson(data['voting_session']);

    participants = (data['participants'] as List<dynamic>)
        .map((e) => Participant.fromJson(e as Map<String, dynamic>))
        .toList();

    jurorsThatSubmitted = (data['jurors_that_submitted'] as List<dynamic>)
        .map((e) => Juror.fromJson(e as Map<String, dynamic>))
        .toList();
    jurorsThatNotSubmitted =
        (data['jurors_that_not_submitted'] as List<dynamic>)
            .map((e) => Juror.fromJson(e as Map<String, dynamic>))
            .toList();

    votingFormFields = (data['voting_form_fields'] as List<dynamic>)
        .map((e) => VotingFormField.fromJson(e as Map<String, dynamic>))
        .toList();

    votesPerJurorMap = (data['votes_per_juror_map'] as Map<Map<String, dynamic>,
            Map<Map<String, dynamic>, List<Map<String, dynamic>>?>>)
        .map<Juror, Map<Participant, List<Vote>?>>(
            (jurorJson, participantAndVotesMapJson) {
      final juror = Juror.fromJson(jurorJson);
      final participantAndVotes = participantAndVotesMapJson.map(
        (key, value) {
          final participant = Participant.fromJson(key);
          final List<Vote>? votes = (value != null)
              ? value.map((e) => Vote.fromJson(e)).toList(growable: false)
              : null;
          return MapEntry(participant, votes);
        },
      );
      return MapEntry(juror, participantAndVotes);
    });

    votesPerParticipantMap = (data['votes_per_participant_map'] as Map<
            Map<String, dynamic>,
            Map<Map<String, dynamic>, List<Map<String, dynamic>>?>>)
        .map<Participant, Map<Juror, List<Vote>?>>(
            (participantJson, jurorAndVotesMapJson) {
      final participant = Participant.fromJson(participantJson);
      final jurorAndVotes = jurorAndVotesMapJson.map(
        (key, value) {
          final juror = Juror.fromJson(key);
          final List<Vote>? votes = (value != null)
              ? value.map((e) => Vote.fromJson(e)).toList(growable: false)
              : null;
          return MapEntry(juror, votes);
        },
      );
      return MapEntry(participant, jurorAndVotes);
    });

    participantsExclusionsPerJurorMap =
        (data['participants_exclusions_per_juror_map']
                as Map<Map<String, dynamic>, List<Map<String, dynamic>>>)
            .map(
      (key, value) {
        final juror = Juror.fromJson(key);
        final List<Participant> participantsExclusions =
            value.map((e) => Participant.fromJson(e)).toList(growable: false);
        return MapEntry(juror, participantsExclusions);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Export'),
      body: ListView(
        children: [
          // Selezione partecipanti
          MultiSelectDialogField<Participant>(
            items: participants
                .map((p) => MultiSelectItem(p, p.fullName))
                .toList(),
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
            items: jurorsThatSubmitted
                .map((j) => MultiSelectItem(j, j.fullName))
                .toList(),
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
            items: votingFormFields
                .map((f) => MultiSelectItem(f, f.name))
                .toList(),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedFields.isEmpty ||
              selectedJurors.isEmpty ||
              selectedParticipants.isEmpty) {
            showSnackBar(
                context: context,
                text:
                    'Select at least one field, one juror and one participant');
            return;
          }

          if (! await requestStoragePermission()) {
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
          sheet.getRangeByIndex(1,1).setText('Partecipante');
          sheet.getRangeByIndex(1,1).cellStyle.hAlign = HAlignType.center;

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
          for (int i = 0; i < participants.length; i++) {
            final participant = participants[i];
            // colonna 1: nome partecipante, riga i+3
            sheet.getRangeByIndex(i + 3, 1).setText(participant.fullName);
            col = 2;
            for (var juror in selectedJurors) {
              final voteList = votesPerParticipantMap[participant]?[juror];
              if (voteList == null) {
                // riempi con "Excluded"
                for (int k = 0; k < selectedFields.length; k++) {
                  sheet.getRangeByIndex(i + 3, col).setText('Excluded');
                  col++;
                }
              } else {
                for (int k = 0; k < selectedFields.length; k++) {
                  sheet.getRangeByIndex(i + 3, col).setText(voteList[k].value);
                  col++;
                }
              }
            }
          }

          var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
          final now = DateTime.now();
          final filename = 'voting_results_${now.year}${now.month}${now.day}${now.hour}${now.minute}${now.second}.xlsx';
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
