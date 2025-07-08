import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/timer_picker_form_field.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

@RoutePage()
class OrganizerVotingSettingsPage extends StatefulWidget {
  final String contestId;

  const OrganizerVotingSettingsPage({
    @PathParam('contestId') required this.contestId,
    super.key,
  });

  @override
  State<OrganizerVotingSettingsPage> createState() => _OrganizerVotingSettingsPageState();
}

class _OrganizerVotingSettingsPageState extends State<OrganizerVotingSettingsPage> {
  late String profileId;
  late final String contestId;

  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();
  final fourthFormKey = GlobalKey<FormState>();
  final fifthFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys =>
      [firstFormKey, secondFormKey, thirdFormKey, fourthFormKey, fifthFormKey];
  int currentStep = 0;

  bool areSimpleJurorsAllowed = false;
  final List<VotingExclusionBundle> votingExclusions = [];
  Duration workTimer = Duration(minutes: 0, seconds: 0);
  Duration intermissionTimer = Duration(minutes: 0, seconds: 0);
  Duration reviewTimer = Duration(minutes: 0, seconds: 0);
  bool isGeoRestricted = false;
  final geoRestrictionPlaceController = TextEditingController();
  final geoRestrictionPlaceFocusNode = FocusNode();
  PlaceModel? geoRestrictionPlace;
  final geoRestrictionRadiusController = TextEditingController();
  final geoRestrictionRadiusFocusNode = FocusNode();
  final List<ParticipationBundle> participationsBundles = [];
  final List<ParticipationBundle> excludedParticipationsBundles = [];
  final List<JurationBundle> jurationsBundles = [];
  final List<JurationBundle> excludedJurationsBundles = [];
  bool isPageInitialized = false;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    profileId = context.read<AuthBloc>().state.profile!.id;
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
    return BlocProvider<OrganizerVotingSettingsPageBloc>(
      create: (context) => OrganizerVotingSettingsPageBloc(
        genericRepository: context.read(),
        organizerRepository: context.read(),
      )..add(OrganizerVotingSettingsPageInit(contestId: contestId)),
      child: BlocConsumer<OrganizerVotingSettingsPageBloc, OrganizerVotingSettingsPageState>(
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
              state.sourceEvent is OrganizerVotingSettingsPageInitVotingProcedure) {
            // context.router.pop(state.votingSessionId);
            context.router
                .replace(OrganizerVotingProcedureRoute(votingSessionId: state.votingSessionId!));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'Voting settings',
            ),
            body: SafeArea(
              child: Builder(
                builder: (context) {
                  switch (state.status) {
                    case BlocStatus.initial:
                      return VoidWidget();
                    case BlocStatus.loading:
                      if (state.sourceEvent is OrganizerVotingSettingsPageInit) {
                        return VoidWidget();
                      } else {
                        continue successCase;
                      }
                    case BlocStatus.failure:
                      if (state.sourceEvent is OrganizerVotingSettingsPageInit) {
                        return RefreshIndicator.adaptive(
                          onRefresh: () async => context
                              .read<OrganizerVotingSettingsPageBloc>()
                              .add(OrganizerVotingSettingsPageInit(contestId: contestId)),
                          child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                        );
                      } else {
                        continue successCase;
                      }
                    successCase:
                    case BlocStatus.success:
                      final contestDetailsBundle = state.contestDetailsBundle!;
                      if (!isPageInitialized) {
                        participationsBundles
                            .addAll(contestDetailsBundle.joinedParticipationsWithWorksBundles);
                        jurationsBundles.addAll(contestDetailsBundle.joinedJurationsBundles);
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
                              context
                                  .read<OrganizerVotingSettingsPageBloc>()
                                  .add(OrganizerVotingSettingsPageInitVotingProcedure(
                                    contestId: contestDetailsBundle.contest.id,
                                    votingFormId:
                                        contestDetailsBundle.votingFormBundle.votingForm.id,
                                    areSimpleJurorsAllowed: areSimpleJurorsAllowed,
                                    votingExclusionsBundles: votingExclusions,
                                    participationsBundles: participationsBundles,
                                    excludedParticipationsBundles: excludedParticipationsBundles,
                                    jurationsBundles: jurationsBundles,
                                    excludedJurationsBundles: excludedJurationsBundles,
                                    workTimer: workTimer,
                                    intermissionTimer: intermissionTimer,
                                    reviewTimer: reviewTimer,
                                    votingFormFields: contestDetailsBundle
                                        .votingFormBundle.votingFormFields
                                        .map((e) => VotingFormFieldModel(
                                            name: e.name,
                                            minValue: e.minValue,
                                            maxValue: e.maxValue,
                                            orderIndex: e.orderIndex))
                                        .toList(growable: false),
                                    isGeoRestricted: isGeoRestricted,
                                    geoRestrictionPlaceAddress: geoRestrictionPlace?.address,
                                    geoRestrictionPlaceLat: geoRestrictionPlace?.lat,
                                    geoRestrictionPlaceLon: geoRestrictionPlace?.lon,
                                    geoRestrictionRadius:
                                        (geoRestrictionRadiusController.text.isNotEmpty)
                                            ? int.tryParse(geoRestrictionRadiusController.text)
                                            : null,
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
                  }
                },
              ),
            ),
          );
        },
      ),
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
                                    // key: ValueKey(participationsBundles[i].participation.id),
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
        //* Second step
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text(''),
          content: Form(
            key: secondFormKey,
            child: FormField(
              validator: (value) => (jurationsBundles.isEmpty) ? '' : null,
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Included jurors
                    Text(
                      'Jurors',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    (jurationsBundles.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: jurationsBundles.length,
                            itemBuilder: (context, index) {
                              final votingJurationBundle = jurationsBundles[index];
                              return Card(
                                elevation: 0.05,
                                child: ListTile(
                                  key: ValueKey(votingJurationBundle.juration.id),
                                  title: Text(votingJurationBundle.juror.fullName),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        excludedJurationsBundles.add(votingJurationBundle);
                                        jurationsBundles.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.remove),
                                  ),
                                ),
                              );
                            })
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No juror included'),
                              if (field.hasError)
                                Text(
                                  'Select at least one juror',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                                ),
                            ],
                          ),
                    SizedBox(height: 64),
                    //* Excluded jurors
                    Text(
                      'Excluded jurors',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                    ),
                    (excludedJurationsBundles.isNotEmpty)
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: excludedJurationsBundles.length,
                            itemBuilder: (context, index) {
                              final excludedJurationBundle = excludedJurationsBundles[index];
                              return Card(
                                elevation: 0.05,
                                child: ListTile(
                                  title: Text(excludedJurationBundle.juror.fullName),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        jurationsBundles.add(excludedJurationBundle);
                                        excludedJurationsBundles.removeAt(index);
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                  ),
                                ),
                              );
                            },
                          )
                        : Text('No juror excluded'),
                  ],
                );
              },
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
                  'Geo restricted',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<bool>(
                  title: Text('True'),
                  value: true,
                  groupValue: isGeoRestricted,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        isGeoRestricted = value;
                      });
                    }
                  },
                ),
                RadioListTile<bool>(
                  title: Text('False'),
                  value: false,
                  groupValue: isGeoRestricted,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        isGeoRestricted = value;
                      });
                    }
                  },
                ),
                SizedBox(height: 8),
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
                            final PlaceModel? placeModel =
                                await context.router.push(PlaceSearchRoute());
                            if (placeModel != null) {
                              geoRestrictionPlaceController.text = placeModel.address!;
                              geoRestrictionPlace = placeModel;
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
                  label: 'Restriction radius',
                  validator: (isGeoRestricted) ? integerValidator : null,
                ),
              ],
            ),
          ),
        ),
        //* Fourth step
        Step(
          state: currentStep >= 4 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 3,
          title: Text(''),
          content: Form(
            key: fourthFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who can vote?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioListTile<bool>.adaptive(
                  title: Text('Only invited jurors'),
                  value: false,
                  groupValue: areSimpleJurorsAllowed,
                  onChanged: (value) {
                    setState(() {
                      areSimpleJurorsAllowed = value!;
                    });
                  },
                ),
                RadioListTile<bool>.adaptive(
                  title: Text('Also simple jurors with the token showed during the voting'),
                  value: true,
                  groupValue: areSimpleJurorsAllowed,
                  onChanged: (value) {
                    setState(() {
                      areSimpleJurorsAllowed = value!;
                    });
                  },
                ),
                SizedBox(height: 64),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voting exclusions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
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
                    final Map<String, dynamic>? votingExclusionBundleJson =
                        await _showAddVotingExclusionDialog(
                            context: context,
                            participations: participationsBundles,
                            jurations: jurationsBundles);
                    if (votingExclusionBundleJson == null) {
                      return;
                    }
                    final votingExclusionBundle =
                        VotingExclusionBundle.fromJson(votingExclusionBundleJson);
                    if (votingExclusions.contains(votingExclusionBundle)) {
                      if (mounted) {
                        showSnackBar(context: context, text: 'Exclusion already added');
                      }
                      return;
                    }
                    if (!areSimpleJurorsAllowed &&
                        participationsBundles.length * jurationsBundles.length ==
                            votingExclusions.length + 1) {
                      if (mounted) {
                        showSnackBar(
                            context: context, text: 'If you add this exclusion no one can vote');
                      }
                      return;
                    }
                    setState(() {
                      votingExclusions.add(votingExclusionBundle);
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
        //* Fifth step
        Step(
          state: currentStep >= 5 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 4,
          title: Text(''),
          content: Form(
            key: fifthFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Work timer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 6),
                TimerPickerFormField(
                  minutes: 0,
                  seconds: 0,
                  onChanged: (minutes, seconds) =>
                      workTimer = Duration(minutes: minutes, seconds: seconds),
                  validator: (_) => _timersValidator(workTimer),
                ),
                SizedBox(height: 20),
                Text(
                  'Intermission timer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 6),
                TimerPickerFormField(
                  minutes: 0,
                  seconds: 0,
                  onChanged: (minutes, seconds) =>
                      intermissionTimer = Duration(minutes: minutes, seconds: seconds),
                  validator: (_) => _timersValidator(intermissionTimer),
                ),
                SizedBox(height: 20),
                Text(
                  'Review timer',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 6),
                TimerPickerFormField(
                  minutes: 0,
                  seconds: 0,
                  onChanged: (minutes, seconds) =>
                      reviewTimer = Duration(minutes: minutes, seconds: seconds),
                  validator: (_) => _timersValidator(reviewTimer),
                ),
              ],
            ),
          ),
        ),
      ];
}

Future<Map<String, dynamic>?> _showAddVotingExclusionDialog({
  required BuildContext context,
  required List<ParticipationBundle> participations,
  required List<JurationBundle> jurations,
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
                    for (var element in participations)
                      DropdownMenuEntry(value: element, label: element.participant.fullName),
                  ],
                ),
                SizedBox(height: 8),
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
                    for (var element in jurations)
                      DropdownMenuEntry(
                        value: element,
                        label: element.juror.fullName,
                      ),
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
                  final votingExclusionBundle = VotingExclusionBundle(
                    participationBundle: chosenParticipationBundle!,
                    jurationBundle: chosenJurationBundle!,
                  );
                  context.router.pop(votingExclusionBundle.toJson());
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

String? _timersValidator(Duration duration) {
  if (duration.inSeconds < 10) {
    return 'At least 10 seconds is required';
  }
  return null;
}
