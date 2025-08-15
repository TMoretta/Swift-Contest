import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/juration_bundle.dart';
import 'package:swift_contest/model/database/bundles/jury_bundle.dart';
import 'package:swift_contest/model/database/bundles/participation_bundle.dart';
import 'package:swift_contest/model/database/entities/jury.dart';
import 'package:swift_contest/model/database/entities/place.dart';
import 'package:swift_contest/model/database/entities/voting_session.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/utils/functions/now.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerVotingSettingsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;

  const OrganizerVotingSettingsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<OrganizerVotingSettingsPage> createState() => _OrganizerVotingSettingsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerVotingSettingsPageBloc>(
      create: (context) => OrganizerVotingSettingsPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerVotingSettingsPageState extends State<OrganizerVotingSettingsPage> {
  late String profileId;
  late final String contestId;

  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();

  // final fourthFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys => [firstFormKey, secondFormKey, thirdFormKey];
  int currentStep = 0;

  final List<({JurationBundle jurationBundle, ParticipationBundle participationBundle})>
      votingExclusions = [];
  bool isGeoRestricted = false;
  final geoRestrictionPlaceController = TextEditingController();
  final geoRestrictionPlaceFocusNode = FocusNode();
  Place? geoRestrictionPlace;
  final geoRestrictionRadiusController = TextEditingController();
  final geoRestrictionRadiusFocusNode = FocusNode();
  final List<ParticipationBundle> participationsBundles = [];
  final List<ParticipationBundle> excludedParticipationsBundles = [];
  final List<JuryBundle> juriesBundles = [];

  // final List<JuryBundle> excludedJuriesBundles = [];
  final List<JurationBundle> jurationsBundles = [];

  // final List<JurationBundle> excludedJurationsBundles = [];
  bool isPageInitialized = false;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id!;
    context.read<OrganizerVotingSettingsPageBloc>().add(OrganizerVotingSettingsPageFetch(
          contestId: contestId,
        ));
  }

  @override
  void dispose() {
    context.hideLoader();
    geoRestrictionPlaceController.dispose();
    geoRestrictionPlaceFocusNode.dispose();
    geoRestrictionRadiusController.dispose();
    geoRestrictionRadiusFocusNode.dispose();
    for (var formKey in formKeys) {
      formKey.currentState?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerVotingSettingsPageBloc, OrganizerVotingSettingsPageState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingSettingsPageStartVotingSession) {
          context.router
              .replace(OrganizerVotingProcedureRoute(votingSessionId: state.votingSessionId!));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: CustomAppBar(title: 'Voting settings'),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                if (!state.isInitialized) {
                  if (state.status.isFailure) {
                    return Center(
                      child: FilledButton(
                        onPressed: () async => context
                            .read<OrganizerVotingSettingsPageBloc>()
                            .add(OrganizerVotingSettingsPageFetch(
                              contestId: contestId,
                            )),
                        child: Text('Retry'),
                      ),
                    );
                  }
                  return VoidWidget();
                }
                final contestDetailsBundle = state.contestDetailsBundle!;
                if (!isPageInitialized) {
                  participationsBundles.addAll(contestDetailsBundle.participationsBundles
                      .where((e) => e.participation.hasSubmitted)
                      .toList());
                  juriesBundles.addAll(contestDetailsBundle.juriesBundles);
                  jurationsBundles.addAll(contestDetailsBundle.juriesBundles
                      .expand((e) => e.jurationsBundles)
                      .toList());
                  isPageInitialized = true;
                }
                return Stepper(
                  type: StepperType.horizontal,
                  currentStep: currentStep,
                  elevation: 0,
                  onStepContinue: () {
                    // FocusManager.instance.primaryFocus?.unfocus();
                    final isLastStep = (currentStep == getSteps().length - 1);
                    if (formKeys[currentStep].currentState?.validate() ?? false) {
                      if (isLastStep) {
                        final createdAt = now();
                        context
                            .read<OrganizerVotingSettingsPageBloc>()
                            .add(OrganizerVotingSettingsPageStartVotingSession(
                              votingSession: VotingSession(
                                id: null,
                                createdAt: null,
                                name:
                                    'Voting ${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}',
                                contestId: contestId,
                                isGeoRestricted: isGeoRestricted,
                                geoResPlaceId: null,
                                geoResRadius: (geoRestrictionRadiusController.text.isNotEmpty)
                                    ? int.tryParse(geoRestrictionRadiusController.text)
                                    : null,
                                sessionStatus: VotingSessionStatus.live,
                              ),
                              geoResPlace: geoRestrictionPlace,
                              participationsBundles: participationsBundles,
                              juriesBundles: juriesBundles,
                              votingExclusions: votingExclusions,
                            ));
                      } else {
                        setState(() => ++currentStep);
                      }
                    }
                  },
                  onStepCancel: () {
                    // FocusManager.instance.primaryFocus?.unfocus();
                    (currentStep == 0) ? null : setState(() => --currentStep);
                  },
                  controlsBuilder: (context, details) {
                    final isLastStep = details.currentStep == getSteps().length - 1;
                    return Container(
                      margin: EdgeInsets.only(top: 64),
                      child: Row(
                        mainAxisAlignment: (currentStep == 0)
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.spaceBetween,
                        spacing: 12,
                        children: [
                          if (details.currentStep != 0)
                            ElevatedButton(
                              onPressed: details.onStepCancel,
                              child: Text('Back'),
                            ),
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            child: Text((isLastStep) ? 'Start' : 'Next'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: getSteps(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  //* Steps
  List<Step> getSteps() => [
        //* First step
        Step(
          state: currentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 0,
          title: Text(''),
          content: Form(
            key: firstFormKey,
            child: FormField(
              validator: (value) => (participationsBundles.isEmpty) ? '' : null,
              builder: (field) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Included participants
                    Text(
                      'Participants',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    (participationsBundles.isNotEmpty)
                        ? ReorderableListView(
                            shrinkWrap: true,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final ParticipationBundle ppw =
                                    participationsBundles.removeAt(oldIndex);
                                participationsBundles.insert(newIndex, ppw);
                              });
                            },
                            children: [
                              for (var i = 0; i < participationsBundles.length; i++)
                                Card(
                                  key: ValueKey(participationsBundles[i].participation.id),
                                  elevation: 0.05,
                                  child: ListTile(
                                    onTap: () {},
                                    title: Text(participationsBundles[i].participant.fullName),
                                    subtitle: Text(participationsBundles[i].work!.name),
                                    leading: Icon(Icons.swap_vert),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          excludedParticipationsBundles
                                              .add(participationsBundles[i]);
                                          participationsBundles.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.remove),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No participant included'),
                              if (field.hasError)
                                Text(
                                  'Select at least one participant',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                                ),
                            ],
                          ),
                    SizedBox(height: 64),
                    //* Excluded participants
                    Text(
                      'Excluded participants',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    (excludedParticipationsBundles.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: excludedParticipationsBundles.length,
                            itemBuilder: (context, index) {
                              final excludedParticipationBundle =
                                  excludedParticipationsBundles[index];
                              return Card(
                                elevation: 0.05,
                                child: ListTile(
                                  title: Text(excludedParticipationBundle.participant.fullName),
                                  subtitle: Text(excludedParticipationBundle.work!.name),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        participationsBundles.add(excludedParticipationBundle);
                                        excludedParticipationsBundles.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              );
                            },
                          )
                        : Text('No participant excluded'),
                  ],
                );
              },
            ),
          ),
        ),
        // //* Second step
        // Step(
        //   state: currentStep >= 2 ? StepState.complete : StepState.indexed,
        //   isActive: currentStep >= 1,
        //   title: Text(''),
        //   content: Form(
        //     key: secondFormKey,
        //     child: FormField(
        //       validator: (value) => (juriesBundles.isEmpty) ? '' : null,
        //       builder: (field) {
        //         return Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             //* Included juries
        //             Text(
        //               'Juries',
        //               style: Theme.of(context)
        //                   .textTheme
        //                   .titleMedium
        //                   ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        //             ),
        //             (juriesBundles.isNotEmpty)
        //                 ? ListView.builder(
        //                     shrinkWrap: true,
        //                     itemCount: juriesBundles.length,
        //                     itemBuilder: (context, index) {
        //                       final juryBundle = juriesBundles[index];
        //                       return Card(
        //                         elevation: 0.05,
        //                         child: ListTile(
        //                           key: ValueKey(juryBundle.jury.id),
        //                           title: Text(juryBundle.jury.name),
        //                           trailing: IconButton(
        //                             onPressed: () {
        //                               setState(() {
        //                                 excludedJuriesBundles.add(juryBundle);
        //                                 juriesBundles.removeAt(index);
        //                               });
        //                             },
        //                             icon: Icon(Icons.remove),
        //                           ),
        //                         ),
        //                       );
        //                     })
        //                 : Column(
        //                     mainAxisSize: MainAxisSize.min,
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Text('No jury included'),
        //                       if (field.hasError)
        //                         Text(
        //                           'Select at least one jury',
        //                           style: Theme.of(context)
        //                               .textTheme
        //                               .labelMedium
        //                               ?.copyWith(color: Theme.of(context).colorScheme.error),
        //                         ),
        //                     ],
        //                   ),
        //             SizedBox(height: 64),
        //             //* Excluded juries
        //             Text(
        //               'Excluded juries',
        //               style: Theme.of(context)
        //                   .textTheme
        //                   .titleMedium
        //                   ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        //             ),
        //             (excludedJuriesBundles.isNotEmpty)
        //                 ? ListView.builder(
        //                     shrinkWrap: true,
        //                     itemCount: excludedJuriesBundles.length,
        //                     itemBuilder: (context, index) {
        //                       final excludedJuryBundle = excludedJuriesBundles[index];
        //                       return Card(
        //                         elevation: 0.05,
        //                         child: ListTile(
        //                           title: Text(excludedJuryBundle.jury.name),
        //                           trailing: IconButton(
        //                             onPressed: () {
        //                               setState(() {
        //                                 juriesBundles.add(excludedJuryBundle);
        //                                 excludedJuriesBundles.removeAt(index);
        //                               });
        //                             },
        //                             icon: Icon(Icons.add),
        //                           ),
        //                         ),
        //                       );
        //                     },
        //                   )
        //                 : Text('No juror excluded'),
        //           ],
        //         );
        //       },
        //     ),
        //   ),
        // ),
        //* Second step
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text(''),
          content: Form(
            key: secondFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Geo restricted',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioGroup<bool>(
                  onChanged: (value) {
                    setState(() {
                      isGeoRestricted = value!;
                    });
                  },
                  groupValue: isGeoRestricted,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile(
                        title: Text('False'),
                        value: false,
                      ),
                      RadioListTile(
                        title: Text('True'),
                        value: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                PlacePickerFormField(
                  controller: geoRestrictionPlaceController,
                  focusNode: geoRestrictionPlaceFocusNode,
                  label: 'Restricted location',
                  validator: (isGeoRestricted) ? noEmptyValidator : null,
                  prefixIcon: Icon(Icons.place_outlined),
                  enabled: isGeoRestricted,
                  suffixIcon: TextButton(
                    onPressed: (isGeoRestricted)
                        ? () async {
                            geoRestrictionPlaceFocusNode.requestFocus();
                            final Place? place = await context.router.push(PlaceSearchRoute());
                            if (place != null) {
                              geoRestrictionPlaceController.text = place.address;
                              geoRestrictionPlace = place;
                            }
                          }
                        : null,
                    child: Text('Select'),
                  ),
                ),
                SizedBox(height: 6),
                CustomTextFormField(
                  borderType: InputBorderType.outlined,
                  enabled: isGeoRestricted,
                  controller: geoRestrictionRadiusController,
                  focusNode: geoRestrictionRadiusFocusNode,
                  label: 'Restriction radius (mt)',
                  validator: (isGeoRestricted) ? integerValidator : null,
                ),
              ],
            ),
          ),
        ),
        //* Third step
        Step(
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text(''),
          content: Form(
            key: thirdFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voting exclusions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 4),
                (votingExclusions.isNotEmpty)
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: votingExclusions.length,
                        itemBuilder: (context, index) {
                          final votingExclusion = votingExclusions[index];
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    'Juror: ',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(votingExclusion.jurationBundle.juror.fullName),
                                  Text(
                                    ' | ',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(juriesBundles
                                      .map((e) => e.jury)
                                      .where((e) =>
                                          votingExclusion.jurationBundle.juration.juryId == e.id)
                                      .first
                                      .name),
                                ],
                              ),
                              subtitle: Row(
                                children: [
                                  Text(
                                    'Participant: ',
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  Text(votingExclusion.participationBundle.participant.fullName),
                                ],
                              ),
                              titleTextStyle: Theme.of(context).textTheme.bodyMedium,
                              subtitleTextStyle: Theme.of(context).textTheme.bodyMedium,
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      votingExclusions.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.remove)),
                            ),
                          );
                        },
                      )
                    : Text('No exclusion added'),
                SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final ({
                      JurationBundle jurationBundle,
                      ParticipationBundle participationBundle
                    })? votingExclusion = await _showAddVotingExclusionDialog(
                        context: context,
                        participationsBundles: participationsBundles,
                        jurationsBundles: jurationsBundles,
                        juries: juriesBundles.map((e) => e.jury).toList(growable: false));
                    if (votingExclusion == null) {
                      return;
                    }
                    if (votingExclusions.contains(votingExclusion)) {
                      if (mounted) {
                        showSnackBar(context: context, text: 'Exclusion already added');
                      }
                      return;
                    }
                    setState(() {
                      votingExclusions.add(votingExclusion);
                    });
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.tertiary),
                  child: Text(
                    'Add',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onTertiary),
                  ),
                ),
              ],
            ),
          ),
        ),
        // //* Fifth step
        // Step(
        //   state: currentStep >= 4 ? StepState.complete : StepState.indexed,
        //   isActive: currentStep >= 3,
        //   title: Text(''),
        //   content: Form(
        //     key: fourthFormKey,
        //     child: Column(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Text(
        //           'Work timer',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         SizedBox(height: 6),
        //         TimerPickerFormField(
        //           minutes: 5,
        //           seconds: 0,
        //           onChanged: (minutes, seconds) =>
        //               workTimer = Duration(minutes: minutes, seconds: seconds),
        //           validator: (_) => _timersValidator(workTimer),
        //         ),
        //         SizedBox(height: 20),
        //         Text(
        //           'Intermission timer',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         SizedBox(height: 6),
        //         TimerPickerFormField(
        //           minutes: 1,
        //           seconds: 0,
        //           onChanged: (minutes, seconds) =>
        //               intermissionTimer = Duration(minutes: minutes, seconds: seconds),
        //           validator: (_) => _timersValidator(intermissionTimer),
        //         ),
        //         SizedBox(height: 20),
        //         Text(
        //           'Review timer',
        //           style: Theme.of(context).textTheme.titleMedium,
        //         ),
        //         SizedBox(height: 6),
        //         TimerPickerFormField(
        //           minutes: 5,
        //           seconds: 0,
        //           onChanged: (minutes, seconds) =>
        //               reviewTimer = Duration(minutes: minutes, seconds: seconds),
        //           validator: (_) => _timersValidator(reviewTimer),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ];
}

Future<({JurationBundle jurationBundle, ParticipationBundle participationBundle})?>
    _showAddVotingExclusionDialog({
  required BuildContext context,
  required List<ParticipationBundle> participationsBundles,
  required List<JurationBundle> jurationsBundles,
  required List<Jury> juries,
}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      ParticipationBundle? chosenParticipationBundle;
      JurationBundle? chosenJurationBundle;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Exclusion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juror',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownMenu(
                  enableSearch: false,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        chosenJurationBundle = value;
                      });
                    }
                  },
                  dropdownMenuEntries: [
                    for (var element in jurationsBundles)
                      DropdownMenuEntry(
                          value: element,
                          label:
                              '${element.juror.fullName} | ${juries.where((e) => e.id == element.juration.juryId).first.name}'),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Participant',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownMenu(
                  enableSearch: false,
                  onSelected: (value) {
                    if (value != null) {
                      setState(() {
                        chosenParticipationBundle = value;
                      });
                    }
                  },
                  dropdownMenuEntries: [
                    for (var element in participationsBundles)
                      DropdownMenuEntry(value: element, label: element.participant.fullName),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.router.pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (chosenParticipationBundle == null || chosenJurationBundle == null) {
                    showSnackBar(context: context, text: 'Fill all the fields');
                    return;
                  }
                  context.router.pop((
                    jurationBundle: chosenJurationBundle,
                    participationBundle: chosenParticipationBundle
                  ));
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
