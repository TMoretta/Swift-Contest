import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session_juror.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/voting_form_field_scope.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/functions/pretty_double.dart';
import 'package:swift_contest/utils/functions/save_and_launch_file.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_ranking_generation_page_bloc/organizer_jury_ranking_generation_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;

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
  List<MapEntry<VotingSessionParticipant, double>>? _generatedRanking;

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
          appBar: const CustomAppBar(title: 'Ranking'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
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
            child: const Text('Retry'),
          ),
        );
      }
      return const VoidWidget();
    }

    return ListView(
      children: [
        const Text(
            'Only fields of type "slider" and in the "participant form" are valid for the ranking generation.'),
        const SizedBox(height: 20),
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
            title: const Text('Select jurors'),
            trailing: const Icon(Icons.arrow_downward),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
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
              if (state.votingSessionJuryResultBundle!.votingSessionJuryBundle.votingFormBundle
                  .participantVotingFormFields
                  .where((e) => e.scope.isParticipant && e.type.isSlider && e.isRequired)
                  .isEmpty) {
                showSnackBar(
                    context: context, text: 'There is no valid field for ranking generation');
                return;
              }
              final selectedFields = await _showSelectFieldsDialog(context, state);
              if (selectedFields != null) {
                selectedVotingFormFields.clear();
                setState(() {
                  selectedVotingFormFields.addAll(selectedFields);
                });
              }
            },
            title: const Text("Select participant's form fields"),
            trailing: const Icon(Icons.arrow_downward),
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 200),
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
                );
              }).toList(),
            ),
          ),
        ),
        if (_generatedRanking != null) _buildRankingDisplay(_generatedRanking!),
        const SizedBox(height: 200),
      ],
    );
  }

  List<MapEntry<VotingSessionParticipant, double>> _calculateRanking(
      OrganizerJuryRankingGenerationPageState state) {
    // Get only submissions from selected jurors
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
          // Use tryParse for safety against non-numeric values
          score += double.tryParse(valueBundle.votingFormSubmissionValue.value) ?? 0.0;
        }

        final oldScore = participantScores[votingSessionParticipant] ?? 0;
        participantScores[votingSessionParticipant] = score + oldScore;
      }
    }

    final sortedParticipantScores = participantScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedParticipantScores;
  }

  Widget _buildFabMenu(BuildContext context, OrganizerJuryRankingGenerationPageState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'generateRanking',
          onPressed: () async {
            if (selectedVotingSessionJurors.isEmpty || selectedVotingFormFields.isEmpty) {
              showSnackBar(context: context, text: 'Select at least one juror and one field');
              return;
            }
            final ranking = _calculateRanking(state);
            setState(() {
              _generatedRanking = ranking;
            });
            showSnackBar(context: context, text: 'Ranking generated successfully.');
          },
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Generate'),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.extended(
          heroTag: 'downloadRanking',
          onPressed: () async {
            if (selectedVotingSessionJurors.isEmpty || selectedVotingFormFields.isEmpty) {
              showSnackBar(context: context, text: 'Select at least one juror and one field');
              return;
            }

            final sortedParticipantScores = _calculateRanking(state);

            // --- Generate Excel File ---
            final xlsio.Workbook workbook = xlsio.Workbook();
            final xlsio.Worksheet sheet = workbook.worksheets[0];
            sheet.name = 'Ranking';

            final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
            headerStyle.bold = true;
            headerStyle.hAlign = xlsio.HAlignType.center;

            sheet.getRangeByName('A1').setText('Participant | Work');
            sheet.getRangeByName('A1').cellStyle = headerStyle;
            sheet.getRangeByName('B1').setText('Score');
            sheet.getRangeByName('B1').cellStyle = headerStyle;

            int rowIndex = 2;
            for (final entry in sortedParticipantScores) {
              final participantName = entry.key.participantFullName;
              final workName = entry.key.workName;
              final score = entry.value;

              sheet.getRangeByName('A$rowIndex').setText('$participantName | $workName');
              sheet.getRangeByName('B$rowIndex').setNumber(score);
              rowIndex++;
            }

            final List<int> fileBytes = workbook.saveAsStream();
            workbook.dispose();

            final fileName =
                'Ranking - ${state.votingSessionJuryResultBundle!.votingSessionJuryBundle.votingSessionJury.juryName}.xlsx';

            // --- Save and Launch File (Platform-Aware) ---
            final (_, message) = await saveAndLaunchFile(fileBytes, fileName);
            if (context.mounted) {
              showSnackBar(context: context, text: message ?? 'File operation completed.');
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('Download'),
        ),
      ],
    );
  }

  Future<List<VotingSessionJuror>?> _showSelectJurorsDialog(
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
              title: const Text('Select jurors'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.router.pop(localSelectedVotingSessionJurors);
                  },
                  child: const Text('Confirm'),
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
    OrganizerJuryRankingGenerationPageState state,
  ) async {
    // Only required fields of the participant form and of type slider considered
    final List<VotingFormField> votingFormFields = state.votingSessionJuryResultBundle!
        .votingSessionJuryBundle.votingFormBundle.participantVotingFormFields
        .where((e) => e.scope.isParticipant && e.type.isSlider && e.isRequired)
        .toList(growable: false);

    final List<VotingFormField> localSelectedVotingFormFields = List.from(selectedVotingFormFields);

    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select valid fields'),
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
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.router.pop(localSelectedVotingFormFields);
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRankingDisplay(List<MapEntry<VotingSessionParticipant, double>> ranking) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0), // Padding to avoid FAB
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Generated Ranking',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const Divider(height: 24),
              if (ranking.isEmpty)
                const Center(child: Text('No scores to display based on selection.'))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ranking.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = ranking[index];
                    final participant = entry.key;
                    final score = entry.value;
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text('${participant.participantFullName} | ${participant.workName}'),
                      trailing: Text(
                        prettyDouble(score),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
