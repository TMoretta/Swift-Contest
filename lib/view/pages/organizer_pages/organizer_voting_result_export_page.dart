import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/media_types.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_export_page_bloc/organizer_voting_result_export_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class OrganizerVotingResultExportPage extends StatefulWidget {
  final String votingSessionId;

  const OrganizerVotingResultExportPage({required this.votingSessionId, super.key});

  @override
  State<OrganizerVotingResultExportPage> createState() => _OrganizerVotingResultExportPageState();
}

class _OrganizerVotingResultExportPageState extends State<OrganizerVotingResultExportPage> {
  late String votingSessionId;
  List<ParticipationBundle> selectedParticipationsBundles = [];
  List<JurationBundle> selectedJurationsBundles = [];
  List<VotingFormField> selectedFields = [];

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
    context
        .read<OrganizerVotingResultExportPageBloc>()
        .add(OrganizerVotingResultExportPageInit(votingSessionId: votingSessionId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Export'),
        body:
            BlocBuilder<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
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
                          OrganizerVotingResultExportPageInit(votingSessionId: votingSessionId));
                    },
                    child: ListView(),
                  );
                }
                continue successCase;
              successCase:
              case BlocStatus.success:
                final participationsBundles = state.votingSessionBundle!.votingSessionParticipationsBundles
                    .map((e) => e.participationBundle)
                    .toList(growable: false);
                final jurationsBundles = state.participantsVotingsPerJurorMap!.entries
                    .map((e) => e.key)
                    .toList(growable: false);
                final votingFormFields =
                    state.votingSessionBundle!.votingFormBundle.votingFormFields;
                return ListView(
                  children: [
                    // Selezione partecipanti
                    MultiSelectDialogField<ParticipationBundle>(
                      items: participationsBundles
                          .map((e) => MultiSelectItem(e, e.participant.fullName))
                          .toList(growable: false),
                      title: Text('Participants'),
                      buttonText: Text('Select participants'),
                      listType: MultiSelectListType.CHIP,
                      initialValue: selectedParticipationsBundles,
                      onConfirm: (values) {
                        setState(() {
                          selectedParticipationsBundles = values;
                        });
                      },
                    ),

                    SizedBox(height: 12),

                    // Selezione giurati
                    MultiSelectDialogField<JurationBundle>(
                      items:
                          jurationsBundles.map((e) => MultiSelectItem(e, e.juror.fullName)).toList(growable: false),
                      title: Text('Jurors'),
                      buttonText: Text('Select jurors'),
                      listType: MultiSelectListType.CHIP,
                      initialValue: selectedJurationsBundles,
                      onConfirm: (values) {
                        setState(() {
                          selectedJurationsBundles = values;
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
            BlocBuilder<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
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
                          OrganizerVotingResultExportPageInit(votingSessionId: votingSessionId));
                    },
                    child: ListView(),
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
                        selectedJurationsBundles.isEmpty ||
                        selectedParticipationsBundles.isEmpty) {
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
                    for (var jurationBundle in selectedJurationsBundles) {
                      int start = col, end = col + selectedFields.length - 1;
                      sheet.getRangeByIndex(1, start, 1, end).merge();
                      sheet.getRangeByIndex(1, start).setText(jurationBundle.juror.fullName);
                      sheet.getRangeByIndex(1, start).cellStyle.hAlign = HAlignType.center;
                      col = end + 1;
                    }
                    sheet.getRangeByIndex(1, 1).setText('Participant');
                    sheet.getRangeByIndex(1, 1).cellStyle.hAlign = HAlignType.center;

                    // Riga 2: nomi dei campi
                    col = 2;
                    for (var jurationBundle in selectedJurationsBundles) {
                      for (var field in selectedFields) {
                        sheet.getRangeByIndex(2, col).setText(field.name);
                        sheet.getRangeByIndex(2, col).cellStyle.hAlign = HAlignType.center;
                        col++;
                      }
                    }

                    // 4) Scrivi il corpo dati
                    final participationsBundles = state
                        .votingSessionBundle!.votingSessionParticipationsBundles
                        .map((e) => e.participationBundle)
                        .toList(growable: false);
                    for (int i = 0; i < participationsBundles.length; i++) {
                      final participationBundle = participationsBundles[i];
                      // colonna 1: nome partecipante, riga i+3
                      sheet.getRangeByIndex(i + 3, 1).setText(participationBundle.participant.fullName);
                      col = 2;
                      for (var jurationBundle in selectedJurationsBundles) {
                        final voteList = jurorsVotingsPerParticipantMap[participationBundle]![jurationBundle];
                        if (voteList == null) {
                          // riempi con "Excluded"
                          for (int k = 0; k < selectedFields.length; k++) {
                            sheet.getRangeByIndex(i + 3, col).setText('Excluded');
                            col++;
                          }
                        } else {
                          for (int k = 0; k < selectedFields.length; k++) {
                            sheet
                                .getRangeByIndex(i + 3, col)
                                .setText(voteList[k].jurorVote.value.toString());
                            col++;
                          }
                        }
                      }
                    }

                    final directory = await ExternalPath.getExternalStoragePublicDirectory(
                        ExternalPath.DIRECTORY_DOWNLOAD);
                    final baseName = state.votingSessionBundle!.votingSession.name;
                    final extension = '.xlsx';

                    String safeFilename;
                    int count = 0;
                    do {
                      safeFilename =
                          (count == 0) ? '$baseName$extension' : '$baseName ($count)$extension';
                      count++;
                    } while (await File('$directory/$safeFilename').exists());

                    final path = '$directory/$safeFilename';

                    final fileBytes = workbook.saveAsStream();
                    workbook.dispose();

                    final file = File(path);
                    try {
                      await file.writeAsBytes(fileBytes, flush: true);
                    } catch (e) {
                      if (context.mounted) {
                        showSnackBar(context: context, text: 'An error occurred');
                      }
                    }

                    if (context.mounted) {
                      showSnackBar(
                          context: context, text: 'File successfully saved in "Downloads" folder');
                    }

                    OpenFile.open(path, type: MediaTypes.mapExtension(extension));
                  },
                  child: Icon(Icons.download),
                );
            }
          },
        ),
      ),
    );
  }
}
