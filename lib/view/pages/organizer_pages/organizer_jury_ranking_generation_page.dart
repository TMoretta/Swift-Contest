import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/utils/functions/request_storage_permissions.dart';
import 'package:swift_contest/utils/logger/logger.dart';
import 'package:swift_contest/utils/media_type.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_ranking_generation_page_bloc/organizer_jury_ranking_generation_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';



@RoutePage()
class OrganizerJuryRankingGenerationPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJuryId;

  const OrganizerJuryRankingGenerationPage({
    @PathParam('votingSessionJuryId') required this.votingSessionJuryId,
    super.key,
  });

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJuryRankingGenerationPageBloc>(
      create: (context) => OrganizerJuryRankingGenerationPageBloc(
        organizerRepository: context.read(),
      )..add(OrganizerJuryRankingGenerationPageFetch(votingSessionJuryId: votingSessionJuryId)),
      child: this,
    );
  }

  @override
  State<OrganizerJuryRankingGenerationPage> createState() =>
      _OrganizerJuryRankingGenerationPageState();
}

class _OrganizerJuryRankingGenerationPageState extends State<OrganizerJuryRankingGenerationPage> {
  late final String votingSessionJuryId;
  List<VotingSessionJuror> selectedVotingSessionJurors = [];
  List<VotingFormField> selectedVotingFormFields = [];

  @override
  void initState() {
    super.initState();
    votingSessionJuryId = widget.votingSessionJuryId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJuryRankingGenerationPageBloc,
        OrganizerJuryRankingGenerationPageState>(
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
          appBar: CustomAppBar(title: 'Ranking'),
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

  Widget _buildBody(BuildContext context, OrganizerJuryRankingGenerationPageState state) {
    if (!state.isInitialized) {
      if (state.status.isFailure) {
        return Center(
          child: FilledButton(
            onPressed: () async => context.read<OrganizerJuryRankingGenerationPageBloc>().add(
                OrganizerJuryRankingGenerationPageFetch(votingSessionJuryId: votingSessionJuryId)),
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

  Widget _buildFabMenu(BuildContext context, OrganizerJuryRankingGenerationPageState state) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (selectedVotingSessionJurors.isEmpty || selectedVotingFormFields.isEmpty) {
          showSnackBar(context: context, text: 'Select at least one juror and one field');
        }
        // Ottieni solo le sottomissioni dei giurati che l'organizzatore ha selezionato
        final submissionsBundles = state.votingSessionJuryResultBundle!.votingFormSubmissionsBundles
            .where((e) => selectedVotingSessionJurors.contains(e.votingSessionJuror))
            .toList(growable: false);

        final Map<VotingSessionParticipant, double> participantScores = {};

        for (var submissionBundle in submissionsBundles) {
          for (var submissionValueBundle
              in submissionBundle.participantVotingFormSubmissionValuesBundles.entries) {
            final votingSessionParticipant = submissionValueBundle.key;
            final valuesBundles = submissionValueBundle.value
                .where((e) => selectedVotingFormFields.contains(e.votingFormField));
            double score = 0;
            for (var valueBundle in valuesBundles) {
              score += double.parse(valueBundle.votingFormSubmissionValue.value);
            }
            valuesBundles.map((e) => e.votingFormSubmissionValue.value);
            final oldScore = participantScores[votingSessionParticipant] ?? 0;
            participantScores.addAll({votingSessionParticipant: score + oldScore});
          }
        }

        for (var participantScore in participantScores.entries) {
          final participant = participantScore.key;
          final score = participantScore.value;

          Logger.debug('${participant.participantFullName} score: ${prettyDouble(score)}');
        }

        final sortedParticipantScores = participantScores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        switch (value) {
          case 'pdf':
            break;
          case 'csv':
            try {
              final request = await requestStoragePermission();
              if (request != true) {
                if (context.mounted) {
                  showSnackBar(context: context, text: 'Can not download file without permission');
                }
                return;
              }

              final directory = await ExternalPath.getExternalStoragePublicDirectory(
                  ExternalPath.DIRECTORY_DOWNLOAD);
              final baseName =
                  'Ranking ${state.votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJury.juryName}';
              final extension = '.csv';

              String safeFilename;
              int count = 0;
              do {
                safeFilename =
                    (count == 0) ? '$baseName$extension' : '$baseName ($count)$extension';
                count++;
              } while (await File('$directory/$safeFilename').exists());

              final path = '$directory/$safeFilename';

              // --- 1. Genera la stringa CSV ---
              final buffer = StringBuffer();

              // Aggiungi l'intestazione delle colonne
              buffer.writeln('Participant,Score');

              // Aggiungi una riga per ogni partecipante
              for (final entry in sortedParticipantScores) {
                final participantName = entry.key.participantFullName;
                final score = entry.value;

                // Metti il nome tra virgolette per gestire eventuali virgole nel nome
                buffer.writeln('"$participantName",${prettyDouble(score)}');
              }

              final file = File(path);
              // Scrivi la stringa nel file
              await file.writeAsString(buffer.toString());

              if (context.mounted) {
                showSnackBar(
                    context: context, text: 'File successfully saved in "Downloads" folder');
              }

              final res = await OpenFile.open(path, type: MediaType.mapExtension(extension));
              switch (res.type) {
                case ResultType.done:
                  break;
                case ResultType.noAppToOpen:
                  if (context.mounted) {
                    showSnackBar(
                        context: context,
                        text: 'No app to open the file. File saved in "Downloads" directory.');
                  }
                  break;
                case ResultType.fileNotFound:
                case ResultType.permissionDenied:
                case ResultType.error:
                  if (context.mounted) {
                    showSnackBar(context: context, text: 'File saved in "Downloads" directory');
                  }
                  break;
              }
            } catch (e) {
              Logger.error(e.toString(), StackTrace.current);
              if (context.mounted) {
                showSnackBar(context: context, text: 'An error occurred while saving the file');
              }
            }
            break;
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'pdf',
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.picture_as_pdf),
                Text('PDF'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'csv',
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.table_view),
                Text('CSV'),
              ],
            ),
          ),
        ];
      },
      icon: Card(
        elevation: 0.5,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
      ),
    );
  }

  Future<List<VotingSessionJuror>>? _showSelectJurorsDialog(
    BuildContext context,
    OrganizerJuryRankingGenerationPageState state,
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

  Future<List<VotingFormField>>? _showSelectFieldsDialog(
    BuildContext context,
    OrganizerJuryRankingGenerationPageState state,
  ) async {
    // Only required fields of the participant form and of type slider considered
    final List<VotingFormField> votingFormFields = state
        .votingSessionJuryResultBundle!.votingSessionJuryBundle.votingFormBundle.votingFormFields
        .where((e) => e.scope.isParticipant && e.type.isSlider && e.isRequired)
        .toList(growable: false);

    final List<VotingFormField> localSelectedVotingFormFields = List.from(selectedVotingFormFields);

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
