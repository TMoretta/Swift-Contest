import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/data_models/simple_juror.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/media_types.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_result_export_page_bloc/organizer_voting_result_export_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

@RoutePage()
class OrganizerVotingResultExportPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const OrganizerVotingResultExportPage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<OrganizerVotingResultExportPage> createState() => _OrganizerVotingResultExportPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingResultExportPageBloc>(
      create: (context) => OrganizerVotingResultExportPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingResultExportPageState extends State<OrganizerVotingResultExportPage> {
  late final String votingSessionId;
  List<ParticipationBundle> selectedParticipationsBundles = [];
  List<JurationBundle> selectedJurationsBundles = [];
  List<SimpleJuror> selectedSimpleJurors = [];
  List<VotingFormField> selectedFields = [];

  @override
  void initState() {
    super.initState();
    votingSessionId = widget.votingSessionId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context
        .read<OrganizerVotingResultExportPageBloc>()
        .add(OrganizerVotingResultExportPageFetch(votingSessionId: votingSessionId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingResultExportPageBloc, OrganizerVotingResultExportPageState>(
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
          appBar: CustomAppBar(title: 'Export'),
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
                        context.read<OrganizerVotingResultExportPageBloc>().add(
                            OrganizerVotingResultExportPageFetch(votingSessionId: votingSessionId));
                      },
                      child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                    );
                  }
                  continue successCase;
                successCase:
                case BlocStatus.success:
                  final votingSessionResultBundle = state.votingSessionResultBundle!;
                  final votingFormFields =
                      votingSessionResultBundle.votingFormBundle.votingFormFields;
                  // Ottengo la lista di participation bundles dei partecipanti non esclusi
                  final participationsBundles = votingSessionResultBundle
                      .votingSessionParticipationsBundles
                      .where((e) => !e.votingSessionParticipation.isExcluded)
                      .map((e) => e.participationBundle)
                      .toList(growable: false);
                  // Ottengo la lista di giurati non esclusi e che hanno inviato i voti
                  final jurationsBundles = votingSessionResultBundle.votingSessionJurationsBundles
                      .where((e) =>
                          !e.votingSessionJuration.isExcluded &&
                          e.votingSessionJuration.hasSubmitted)
                      .map((e) => e.jurationBundle)
                      .toList(growable: false);
                  // Ottengo la lista di giurati semplici che hanno inviato i voti
                  final simpleJurors = votingSessionResultBundle.votingSessionSimpleJurorsBundles
                      .where((e) => e.votingSessionSimpleJuror.hasSubmitted)
                      .map((e) => e.simpleJuror)
                      .toList(growable: false);
                  return ListView(
                    children: [
                      SizedBox(height: 16),
                      // Selezione partecipanti
                      MultiSelectDialogField<ParticipationBundle>(
                        items: participationsBundles
                            .map((e) => MultiSelectItem(e, e.participant.fullName))
                            .toList(growable: false),
                        title: Text('Participants'),
                        buttonText: Text('Select participants'),
                        initialValue: selectedParticipationsBundles,
                        onConfirm: (values) {
                          setState(() {
                            selectedParticipationsBundles = values;
                          });
                        },
                        listType: MultiSelectListType.LIST,
                        dialogHeight: 250,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                        selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                      ),

                      SizedBox(height: 20),

                      // Selezione giurati
                      if (jurationsBundles.isNotEmpty)
                        MultiSelectDialogField<JurationBundle>(
                          items: jurationsBundles
                              .map((e) => MultiSelectItem(e, e.juror.fullName))
                              .toList(growable: false),
                          title: Text('Jurors'),
                          buttonText: Text('Select jurors'),
                          initialValue: selectedJurationsBundles,
                          onConfirm: (values) {
                            setState(() {
                              selectedJurationsBundles = values;
                            });
                          },
                          listType: MultiSelectListType.LIST,
                          dialogHeight: 250,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                          selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                          checkColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      if (jurationsBundles.isNotEmpty) SizedBox(height: 20),

                      // Selezione giurati semplici
                      if (simpleJurors.isNotEmpty)
                        MultiSelectDialogField<SimpleJuror>(
                          items: simpleJurors
                              .map((e) => MultiSelectItem(e, e.fullName))
                              .toList(growable: false),
                          title: Text('Simple jurors'),
                          buttonText: Text('Select simple jurors'),
                          initialValue: selectedSimpleJurors,
                          onConfirm: (values) {
                            setState(() {
                              selectedSimpleJurors = values;
                            });
                          },
                          listType: MultiSelectListType.LIST,
                          dialogHeight: 250,
                          selectedColor: Theme.of(context).colorScheme.primary,
                          itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                          selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                          checkColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      if (simpleJurors.isNotEmpty) SizedBox(height: 20),

                      // Selezione campi del form
                      MultiSelectDialogField<VotingFormField>(
                        items: votingFormFields.map((f) => MultiSelectItem(f, f.name)).toList(),
                        title: Text('Fields'),
                        buttonText: Text('Select fields'),
                        initialValue: selectedFields,
                        onConfirm: (values) {
                          setState(() {
                            selectedFields = values;
                          });
                        },
                        listType: MultiSelectListType.LIST,
                        dialogHeight: 250,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                        selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
                        checkColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ],
                  );
              }
            },
          ),
          floatingActionButton: Builder(
            builder: (context) {
              switch (state.status) {
                case BlocStatus.initial:
                  return VoidWidget();
                case (BlocStatus.loading || BlocStatus.failure):
                  if(!state.isInitialized) {
                    return VoidWidget();
                  } else {
                    continue successCase;
                  }
                successCase:
                case BlocStatus.success:
                  final votingSessionResultBundle = state.votingSessionResultBundle!;
                  final jurorsVotingsPerParticipantMap =
                      votingSessionResultBundle.jurorsVotingsPerParticipantMap;
                  final simpleJurorsVotingsPerParticipantMap =
                      votingSessionResultBundle.simpleJurorsVotingsPerParticipantMap;
                  return FloatingActionButton(
                    onPressed: () async {
                      if (selectedFields.isEmpty ||
                          (selectedJurationsBundles.isEmpty && selectedSimpleJurors.isEmpty) ||
                          selectedParticipationsBundles.isEmpty) {
                        showSnackBar(
                            context: context,
                            text:
                                'Select at least one field, one juror or simple juror, and one participant');
                        return;
                      }

                      if (!await requestStoragePermission()) {
                        if (context.mounted) {
                          showSnackBar(context: context, text: 'Permission denied');
                        }
                        return;
                      }

                      final xlsio.Workbook workbook = xlsio.Workbook();
                      final xlsio.Worksheet sheet = workbook.worksheets[0];
                      sheet.name = 'Results';

                      int rowIndex = 1;
                      int colIndex = 1;

                      //* Jurors
                      if(selectedJurationsBundles.isNotEmpty) {
                        sheet.getRangeByIndex(rowIndex, colIndex).setText('Jurors');
                        ++colIndex;
                        for (var participationBundle in selectedParticipationsBundles) {
                          int start = colIndex;
                          int end = colIndex + selectedFields.length - 1;
                          sheet.getRangeByIndex(rowIndex, start, 1, end).merge();
                          sheet
                              .getRangeByIndex(rowIndex, start)
                              .setText(participationBundle.participant.fullName);
                          sheet.getRangeByIndex(rowIndex, start).cellStyle.hAlign =
                              xlsio.HAlignType.center;
                          colIndex = end + 1;
                        }

                        ++rowIndex;
                        // Riga 2: nomi dei campi
                        colIndex = 2;
                        for (int i = 0; i < selectedParticipationsBundles.length; i++) {
                          for (var field in selectedFields) {
                            sheet.getRangeByIndex(rowIndex, colIndex).setText(field.name);
                            sheet.getRangeByIndex(rowIndex, colIndex).cellStyle.hAlign =
                                xlsio.HAlignType.center;
                            colIndex++;
                          }
                        }

                        ++rowIndex;

                        // 4) Scrivi il corpo dati
                        for (var jurationBundle in selectedJurationsBundles) {
                          sheet.getRangeByIndex(rowIndex, 1).setText(jurationBundle.juror.fullName);
                          colIndex = 2;
                          for (var participationBundle in selectedParticipationsBundles) {
                            for (int i = 0; i < selectedFields.length; i++) {
                              final jurorVoteBundle =
                              jurorsVotingsPerParticipantMap[participationBundle]![jurationBundle]
                              ?[i];
                              if (jurorVoteBundle != null) {
                                sheet
                                    .getRangeByIndex(rowIndex, colIndex)
                                    .setText(jurorVoteBundle.jurorVote.value.toString());
                                colIndex++;
                              } else {
                                sheet.getRangeByIndex(rowIndex, colIndex).setText('Excluded');
                                colIndex++;
                              }
                            }
                          }
                          ++rowIndex;
                        }

                        ++rowIndex;
                        ++rowIndex;
                      }

                      //* Simple Jurors
                      if(selectedSimpleJurors.isNotEmpty) {
                        sheet.getRangeByIndex(rowIndex, 1).setText('Simple jurors');
                        // headers
                        colIndex = 2;
                        for (var participationBundle in selectedParticipationsBundles) {
                          int start = colIndex;
                          int end = colIndex + selectedFields.length - 1;
                          sheet.getRangeByIndex(rowIndex, start, 1, end).merge();
                          sheet
                              .getRangeByIndex(rowIndex, start)
                              .setText(participationBundle.participant.fullName);
                          sheet.getRangeByIndex(rowIndex, start).cellStyle.hAlign =
                              xlsio.HAlignType.center;
                          colIndex = end + 1;
                        }

                        ++rowIndex;
                        // Riga 2: nomi dei campi
                        colIndex = 2;
                        for (int i = 0; i < selectedParticipationsBundles.length; i++) {
                          for (var field in selectedFields) {
                            sheet.getRangeByIndex(rowIndex, colIndex).setText(field.name);
                            sheet.getRangeByIndex(rowIndex, colIndex).cellStyle.hAlign =
                                xlsio.HAlignType.center;
                            colIndex++;
                          }
                        }

                        ++rowIndex;

                        for (var simpleJuror in selectedSimpleJurors) {
                          sheet.getRangeByIndex(rowIndex, 1).setText(simpleJuror.fullName);
                          colIndex = 2;
                          for (var participationBundle in selectedParticipationsBundles) {
                            for (int i = 0; i < selectedFields.length; i++) {
                              final simpleJurorVoteBundle = simpleJurorsVotingsPerParticipantMap[
                              participationBundle]![simpleJuror]![i];
                              sheet
                                  .getRangeByIndex(rowIndex, colIndex)
                                  .setText(simpleJurorVoteBundle.simpleJurorVote.value.toString());
                              colIndex++;
                            }
                          }
                          ++rowIndex;
                        }
                      }

                      try {
                        final directory = await ExternalPath.getExternalStoragePublicDirectory(
                            ExternalPath.DIRECTORY_DOWNLOAD);
                        final baseName =
                            state.votingSessionResultBundle!.votingSessionBundle.votingSession.name;
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
                        await file.writeAsBytes(fileBytes, flush: true);

                        if (context.mounted) {
                          showSnackBar(
                              context: context,
                              text: 'File successfully saved in "Downloads" folder');
                        }

                        OpenFile.open(path, type: MediaTypes.mapExtension(extension));
                      } catch (e) {
                        if (context.mounted) {
                          showSnackBar(context: context, text: Labels.anErrorOccurred);
                        }
                      }
                    },
                    child: Icon(Icons.download),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
