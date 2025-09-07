import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/utils/media_type.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_voting_results_export_page_bloc/organizer_jury_voting_results_export_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerJuryVotingResultsExportPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJuryId;

  const OrganizerJuryVotingResultsExportPage({
    @PathParam('votingSessionJuryId') required this.votingSessionJuryId,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJuryVotingResultsExportPageBloc>(
      create: (context) => OrganizerJuryVotingResultsExportPageBloc(
        organizerRepository: context.read(),
      )..add(OrganizerJuryVotingResultsExportPageFetch(votingSessionJuryId: votingSessionJuryId)),
      child: this,
    );
  }

  @override
  State<OrganizerJuryVotingResultsExportPage> createState() =>
      _OrganizerJuryVotingResultsExportPageState();
}

class _OrganizerJuryVotingResultsExportPageState
    extends State<OrganizerJuryVotingResultsExportPage> {
  late final String votingSessionJuryId;
  List<VotingSessionJuror> selectedVotingSessionJurors = [];
  List<VotingFormField> selectedVotingFormFields = [];

  @override
  void initState() {
    super.initState();
    votingSessionJuryId = widget.votingSessionJuryId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJuryVotingResultsExportPageBloc,
        OrganizerJuryVotingResultsExportPageState>(
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
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: _buildBody(context, state),
            ),
          ),
          floatingActionButton: (state.isInitialized) ? _buildFabMenu(context, state) : null,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, OrganizerJuryVotingResultsExportPageState state) {
    if (!state.isInitialized) {
      if (state.status.isFailure) {
        return Center(
          child: FilledButton(
            onPressed: () async => context.read<OrganizerJuryVotingResultsExportPageBloc>().add(
                OrganizerJuryVotingResultsExportPageFetch(
                    votingSessionJuryId: votingSessionJuryId)),
            child: Text('Retry'),
          ),
        );
      }
      return VoidWidget();
    }

    return ListView(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
          child: ListTile(
            onTap: () async {
              final selectedJurors = await _showSelectJurorsDialog(context, state);
              if (selectedJurors != null) {
                selectedVotingSessionJurors.clear();
                setState(() {
                  selectedVotingSessionJurors.addAll(selectedJurors);
                });
              }
            },
            title: Text('Select jurors'),
            trailing: Icon(Icons.arrow_downward),
          ),
        ),
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Wrap(
              // Spazio orizzontale tra i chip sulla stessa riga
              spacing: 8.0,
              // Spazio verticale tra le righe di chip
              runSpacing: 4.0,
              // Mappa la tua lista di giurati a una lista di widget Chip
              children: selectedVotingSessionJurors.map((juror) {
                return Chip(
                  label: Text(juror.jurorFullName),
                  // Puoi anche aggiungere un'azione di cancellazione se necessario
                  // onDeleted: () {
                  //   setState(() {
                  //     selectedVotingSessionJurors.remove(juror);
                  //   });
                  // },
                );
              }).toList(), // .toList() è fondamentale per convertire l'Iterable in una List<Widget>
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary)),
          ),
          child: ListTile(
            onTap: () async {
              final selectedFields = await _showSelectFieldsDialog(context, state);
              if (selectedFields != null) {
                selectedVotingFormFields.clear();
                setState(() {
                  selectedVotingFormFields.addAll(selectedFields);
                });
              }
            },
            title: Text('Select fields'),
            trailing: Icon(Icons.arrow_downward),
          ),
        ),
        SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200),
          child: SingleChildScrollView(
            child: Wrap(
              // Spazio orizzontale tra i chip sulla stessa riga
              spacing: 8.0,
              // Spazio verticale tra le righe di chip
              runSpacing: 4.0,
              // Mappa la tua lista di giurati a una lista di widget Chip
              children: selectedVotingFormFields.map((votingFormField) {
                return Chip(
                  label: Text(votingFormField.question),
                  // Puoi anche aggiungere un'azione di cancellazione se necessario
                  // onDeleted: () {
                  //   setState(() {
                  //     selectedVotingSessionJurors.remove(juror);
                  //   });
                  // },
                );
              }).toList(), // .toList() è fondamentale per convertire l'Iterable in una List<Widget>
            ),
          ),
        ),

        // MultiSelectDialogField<VotingSessionJuror>(
        //   items: votingSessionJurors
        //       .map((e) => MultiSelectItem(e, e.jurorFullName))
        //       .toList(growable: false),
        //   title: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Text('Jurors'),
        //       TextButton(onPressed: (){}, child: Text('Select all'),),
        //     ],
        //   ),
        //   buttonText: Text('Select jurors'),
        //   initialValue: selectedVotingSessionJurors,
        //   onSelectionChanged: (p0) {
        //
        //   },
        //   onConfirm: (values) {
        //     setState(() {
        //       selectedVotingSessionJurors = values;
        //     });
        //   },
        //   listType: MultiSelectListType.LIST,
        //   dialogHeight: 250,
        //   selectedColor: Theme.of(context).colorScheme.primary,
        //   itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
        //   selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
        //   checkColor: Theme.of(context).colorScheme.onPrimary,
        // ),
        // SizedBox(height: 20),
        // MultiSelectDialogField<VotingFormField>(
        //   items:
        //       votingFormFields.map((f) => MultiSelectItem(f, f.question)).toList(growable: false),
        //   title: Text('Fields'),
        //   buttonText: Text('Select fields'),
        //   initialValue: selectedVotingFormFields,
        //   onConfirm: (values) {
        //     setState(() {
        //       selectedVotingFormFields = values;
        //     });
        //   },
        //   listType: MultiSelectListType.LIST,
        //   dialogHeight: 250,
        //   selectedColor: Theme.of(context).colorScheme.primary,
        //   itemsTextStyle: Theme.of(context).textTheme.bodyMedium,
        //   selectedItemsTextStyle: Theme.of(context).textTheme.bodyMedium,
        //   checkColor: Theme.of(context).colorScheme.onPrimary,
        // ),
      ],
    );
  }

  Widget _buildFabMenu(BuildContext context, OrganizerJuryVotingResultsExportPageState state) {
    return FloatingActionButton.extended(
      onPressed: () async {
        if (selectedVotingSessionJurors.isEmpty || selectedVotingFormFields.isEmpty) {
          showSnackBar(context: context, text: 'Select at least one juror and one field');
          return;
        }

        // --- 1. Filter selected fields by scope ---
        final headerFields =
            selectedVotingFormFields.where((f) => f.scope.isHeader).toList(growable: false);
        final participantFields =
            selectedVotingFormFields.where((f) => f.scope.isParticipant).toList(growable: false);
        final footerFields =
            selectedVotingFormFields.where((f) => f.scope.isFooter).toList(growable: false);

        // --- 2. Pre-process submissions into efficient lookup maps ---
        final allParticipants = state.votingSessionJuryResultBundle!.votingSessionParticipants;
        final allSubmissions = state.votingSessionJuryResultBundle!.votingFormSubmissionsBundles;
        final exclusions = state.votingSessionJuryResultBundle!.votingSessionExclusions;

        final votesMap = <String, Map<String, String>>{}; // { jurorId: { fieldId: value } }
        final participantVotesMap =
            <String, Map<String, Map<String, String>>>{}; // { jurorId: { participantId: { fieldId: value } } }

        for (final submission in allSubmissions) {
          final jurorId = submission.votingSessionJuror.id!;
          votesMap[jurorId] = {};
          participantVotesMap[jurorId] = {};

          for (final valueBundle in submission.votingFormSubmissionValuesBundles) {
            final fieldId = valueBundle.votingFormField.id!;
            final value = valueBundle.votingFormSubmissionValue.value;

            if (valueBundle.votingFormField.scope.isParticipant) {
              final participantId = valueBundle.votingSessionParticipant!.id;
              if (participantVotesMap[jurorId]![participantId] == null) {
                participantVotesMap[jurorId]![participantId!] = {};
              }
              participantVotesMap[jurorId]![participantId]![fieldId] = value;
            } else {
              votesMap[jurorId]![fieldId] = value;
            }
          }
        }

        // --- 3. Build the Excel file ---
        final xlsio.Workbook workbook = xlsio.Workbook();
        final xlsio.Style headerStyle = workbook.styles.add('headerStyle')..bold = true;
        int sheetCounter = 0;

        // Helper function to get a new or existing sheet. This avoids creating a sheet
        // and then deleting the default one, which is more efficient and robust.
        xlsio.Worksheet getSheet(String name) {
          if (sheetCounter == 0) {
            final sheet = workbook.worksheets[0];
            sheet.name = name;
            sheetCounter++;
            return sheet;
          } else {
            return workbook.worksheets.addWithName(name);
          }
        }

        // --- Header Sheet ---
        if (headerFields.isNotEmpty) {
          final xlsio.Worksheet sheet = getSheet('Header form');
          sheet.getRangeByName('A1').setText('Juror');
          sheet.getRangeByName('A1').cellStyle = headerStyle;

          for (int i = 0; i < headerFields.length; i++) {
            sheet.getRangeByIndex(1, i + 2).setText(headerFields[i].question);
            sheet.getRangeByIndex(1, i + 2).cellStyle = headerStyle;
          }

          for (int r = 0; r < selectedVotingSessionJurors.length; r++) {
            final juror = selectedVotingSessionJurors[r];
            sheet.getRangeByIndex(r + 2, 1).setText(juror.jurorFullName);
            for (int c = 0; c < headerFields.length; c++) {
              final field = headerFields[c];
              final value = votesMap[juror.id]?[field.id] ?? '';
              sheet.getRangeByIndex(r + 2, c + 2).setText(value);
            }
          }
        }

        // --- Participant Sheet ---
        if (participantFields.isNotEmpty) {
          final xlsio.Worksheet sheet = getSheet("Participant's form");
          sheet.getRangeByName('A1').setText('Juror');
          sheet.getRangeByName('A1').cellStyle = headerStyle;
          sheet.getRangeByName('B1').setText('Field');
          sheet.getRangeByName('B1').cellStyle = headerStyle;

          for (int i = 0; i < allParticipants.length; i++) {
            final participant = allParticipants[i];
            sheet
                .getRangeByIndex(1, i + 3)
                .setText('${participant.participantFullName} | ${participant.workName}');
            sheet.getRangeByIndex(1, i + 3).cellStyle = headerStyle;
          }

          int currentRow = 2;
          for (final juror in selectedVotingSessionJurors) {
            final startRow = currentRow;
            for (int i = 0; i < participantFields.length; i++) {
              final field = participantFields[i];
              sheet.getRangeByIndex(currentRow + i, 2).setText(field.question);

              for (int p = 0; p < allParticipants.length; p++) {
                final participant = allParticipants[p];
                final isExcluded = exclusions.any((ex) =>
                    ex.votingSessionJurorId == juror.id &&
                    ex.votingSessionParticipantId == participant.id);

                if (isExcluded) {
                  sheet.getRangeByIndex(currentRow + i, p + 3).setText('Excluded');
                } else {
                  final value = participantVotesMap[juror.id]?[participant.id]?[field.id] ?? '';
                  sheet.getRangeByIndex(currentRow + i, p + 3).setText(value);
                }
              }
            }
            final endRow = currentRow + participantFields.length - 1;
            sheet.getRangeByName('A$startRow:A$endRow').merge();
            sheet.getRangeByName('A$startRow').setText(juror.jurorFullName);
            sheet.getRangeByName('A$startRow').cellStyle.vAlign = xlsio.VAlignType.center;

            currentRow += participantFields.length;
          }
        }

        // --- Footer Sheet ---
        if (footerFields.isNotEmpty) {
          final xlsio.Worksheet sheet = getSheet('Footer form');
          sheet.getRangeByName('A1').setText('Juror');
          sheet.getRangeByName('A1').cellStyle = headerStyle;

          for (int i = 0; i < footerFields.length; i++) {
            sheet.getRangeByIndex(1, i + 2).setText(footerFields[i].question);
            sheet.getRangeByIndex(1, i + 2).cellStyle = headerStyle;
          }

          for (int r = 0; r < selectedVotingSessionJurors.length; r++) {
            final juror = selectedVotingSessionJurors[r];
            sheet.getRangeByIndex(r + 2, 1).setText(juror.jurorFullName);
            for (int c = 0; c < footerFields.length; c++) {
              final field = footerFields[c];
              final value = votesMap[juror.id]?[field.id] ?? '';
              sheet.getRangeByIndex(r + 2, c + 2).setText(value);
            }
          }
        }

        try {
          final directory =
              await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOAD);
          final baseName =
              'Results - ${state.votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJury.juryName}';
          const extension = '.xlsx';

          String safeFilename;
          int count = 0;
          do {
            safeFilename = (count == 0) ? '$baseName$extension' : '$baseName ($count)$extension';
            count++;
          } while (await File('$directory/$safeFilename').exists());

          final path = '$directory/$safeFilename';
          final List<int> fileBytes = workbook.saveAsStream();
          workbook.dispose();
          final file = File(path);
          await file.writeAsBytes(fileBytes);

          if (!context.mounted) return;
          showSnackBar(context: context, text: 'File successfully saved in "Downloads" folder');

          final res = await OpenFilex.open(path, type: MediaType.mapExtension(extension));
          if (res.type != ResultType.done && context.mounted) {
            showSnackBar(
                context: context,
                text: 'No app to open the file. File saved in "Downloads" directory.');
          }
        } catch (e) {
          Logger.error(e.toString(), StackTrace.current);
          if (context.mounted) {
            showSnackBar(context: context, text: 'An error occurred while saving the file');
          }
        }
      },
      icon: Icon(Icons.download),
      label: Text('Export to Excel'),
    );
  }

  Future<List<VotingSessionJuror>?> _showSelectJurorsDialog(
    BuildContext context,
    OrganizerJuryVotingResultsExportPageState state,
  ) async {
    // Only voting session jurors with submission considered
    final List<VotingSessionJuror> votingSessionJurors = state
        .votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJurors
        .where((e) => e.hasSubmitted)
        .toList(growable: false);

    final List<VotingSessionJuror> localSelectedVotingSessionJurors =
        List.from(selectedVotingSessionJurors);

    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select jurors'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            final bool areAllSelected = localSelectedVotingSessionJurors.length ==
                                votingSessionJurors.length;

                            if (areAllSelected) {
                              localSelectedVotingSessionJurors.clear();
                            } else {
                              localSelectedVotingSessionJurors.clear();
                              localSelectedVotingSessionJurors.addAll(votingSessionJurors);
                            }
                          });
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
                        child: Text(
                          (localSelectedVotingSessionJurors.length == votingSessionJurors.length)
                              ? 'Deselect all'
                              : 'Select all',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ),
                    ...votingSessionJurors.map((votingSessionJuror) {
                      return CheckboxListTile(
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              localSelectedVotingSessionJurors.add(votingSessionJuror);
                            } else {
                              localSelectedVotingSessionJurors.remove(votingSessionJuror);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        value: localSelectedVotingSessionJurors.contains(votingSessionJuror),
                        title: Text(votingSessionJuror.jurorFullName),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.router.pop(localSelectedVotingSessionJurors);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<VotingFormField>?> _showSelectFieldsDialog(
    BuildContext context,
    OrganizerJuryVotingResultsExportPageState state,
  ) async {
    // Only required fields of the participant form and of type slider considered
    final List<VotingFormField> votingFormFields = state
        .votingSessionJuryResultBundle!.votingSessionJuryBundle.votingFormBundle.votingFormFields
        .toList(growable: false);

    final List<VotingFormField> localSelectedVotingFormFields = List.from(selectedVotingFormFields);

    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select fields'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            final bool areAllSelected =
                                localSelectedVotingFormFields.length == votingFormFields.length;

                            if (areAllSelected) {
                              localSelectedVotingFormFields.clear();
                            } else {
                              localSelectedVotingFormFields.clear();
                              localSelectedVotingFormFields.addAll(votingFormFields);
                            }
                          });
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer),
                        child: Text(
                          (localSelectedVotingFormFields.length == votingFormFields.length)
                              ? 'Deselect all'
                              : 'Select all',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: Theme.of(context).colorScheme.onTertiaryContainer),
                        ),
                      ),
                    ),
                    ...votingFormFields.map((votingFormField) {
                      return CheckboxListTile(
                        onChanged: (value) {
                          setState(() {
                            if (value!) {
                              localSelectedVotingFormFields.add(votingFormField);
                            } else {
                              localSelectedVotingFormFields.remove(votingFormField);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        value: localSelectedVotingFormFields.contains(votingFormField),
                        title: Text(votingFormField.question),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.router.pop(),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.router.pop(localSelectedVotingFormFields);
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
