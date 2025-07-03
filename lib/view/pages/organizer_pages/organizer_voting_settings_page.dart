import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/data_models/place.dart';
import 'package:swift_contest/model/data_models/voting_form_field.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_form_field_bloc/place_picker_form_field_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingSettingsPage extends StatefulWidget {
  final String contestId;

  const OrganizerVotingSettingsPage({required this.contestId, super.key});

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
  Duration workTimer = Duration(minutes: 0, seconds: 10);
  Duration intermissionTimer = Duration(minutes: 0, seconds: 10);
  Duration reviewTimer = Duration(minutes: 0, seconds: 20);
  bool isGeoRestricted = false;
  final geoRestrictionPlaceController = TextEditingController();
  PlaceNullable? geoRestrictionPlace;
  final geoRestrictionRadiusController = TextEditingController();
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
    context
        .read<OrganizerVotingSettingsPageBloc>()
        .add(OrganizerVotingSettingsPageInit(contestId: contestId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrganizerVotingSettingsPageBloc, OrganizerVotingSettingsPageState>(
      listener: (context, state) {
        if (state.status.isFailure) {
          showSnackBar(context: context, text: state.message!);
        }
        if(state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.status.isSuccess &&
            state.sourceEvent is OrganizerVotingSettingsPageInitVotingProcedure) {
          context.pop(state.votingSessionId);
          // context.replaceNamed(AppRouter.organizerVotingProcedure, extra: state.votingSessionId);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Voting settings',
        ),
        body: SafeArea(
          child: BlocBuilder<OrganizerVotingSettingsPageBloc, OrganizerVotingSettingsPageState>(
            builder: (context, state) {
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
                  if(!isPageInitialized) {
                    participationsBundles.addAll(contestDetailsBundle.joinedParticipationsWithWorksBundles);
                    jurationsBundles.addAll(contestDetailsBundle.joinedJurationsBundles);
                    isPageInitialized = true;
                  }
                  return Stepper(
                    type: StepperType.horizontal,
                    currentStep: currentStep,
                    elevation: 0,
                    onStepContinue: () {
                      FocusManager.instance.primaryFocus?.unfocus();
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
                                    .map((e) => VotingFormFieldNullable(
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
                      FocusManager.instance.primaryFocus?.unfocus();
                      (currentStep == 0) ? null : setState(() => --currentStep);
                    },
                    controlsBuilder: (context, details) {
                      final isLastStep = details.currentStep == getSteps().length - 1;
                      return Container(
                        margin: EdgeInsets.only(top: 20),
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
                return SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight - 200,
                  child: Column(
                    children: [
                      //* Included participants
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Participants',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      (participationsBundles.isNotEmpty)
                          ? Expanded(
                              child: ReorderableListView(
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
                              ),
                            )
                          : Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
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
                              ),
                            ),
                      //* Excluded participants
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Excluded participants',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      (excludedParticipationsBundles.isNotEmpty)
                          ? Expanded(
                              child: ListView.builder(
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
                              ),
                            )
                          : Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text('No participant excluded'),
                              ),
                            ),
                    ],
                  ),
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
                return SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight - 200,
                  child: Column(
                    children: [
                      //* Included jurors
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Jurors',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      (jurationsBundles.isNotEmpty)
                          ? Expanded(
                              child: ListView.builder(
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
                                  }),
                            )
                          : Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
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
                              ),
                            ),
                      //* Excluded jurors
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Excluded jurors',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      (excludedJurationsBundles.isNotEmpty)
                          ? Expanded(
                              child: ListView.builder(
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
                              ),
                            )
                          : Expanded(
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text('No juror excluded'),
                              ),
                            ),
                    ],
                  ),
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 200,
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Geo restricted',
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
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
                    label: 'Restricted location',
                    validator: (isGeoRestricted) ? noEmptyValidator : null,
                    prefixIcon: Icon(Icons.place_outlined),
                    suffixIcon: TextButton(
                      onPressed: () async {
                        final PlaceNullable? placeNullable = await context.pushNamed(AppRouter.placeSearch);
                        if(placeNullable!=null) {
                          geoRestrictionPlaceController.text = placeNullable.address!;
                          geoRestrictionPlace = placeNullable;
                        }
                      },
                      child: Text('Select'),
                    ),
                  ),
                  SizedBox(height: 6),
                  CustomTextFormField(
                    borderType: InputBorderType.outlined,
                    enabled: isGeoRestricted,
                    controller: geoRestrictionRadiusController,
                    label: 'Restriction radius',
                    validator: (isGeoRestricted) ? integerValidator : null,
                  ),
                ],
              ),
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 200,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Who can vote',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    title: Text('Anyone with a session token (showed during the procedure)'),
                    value: true,
                    groupValue: areSimpleJurorsAllowed,
                    onChanged: (value) {
                      setState(() {
                        areSimpleJurorsAllowed = value!;
                      });
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Voting exclusions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      FilledButton(
                        onPressed: () async {
                          final VotingExclusionBundle? votingExclusionBundle =
                              await _showAddVotingExclusionDialog(
                                  context: context,
                                  participations: participationsBundles,
                                  jurations: jurationsBundles);
                          if (votingExclusionBundle == null) {
                            return;
                          }
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
                                  context: context,
                                  text: 'If you add this exclusion no one can vote');
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
                  SizedBox(height: 4),
                  Expanded(
                    child: (votingExclusions.isNotEmpty)
                        ? ListView.builder(
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
                                      Text(
                                          votingExclusion.participationBundle.participant.fullName),
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
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Text('No exclusion added'),
                          ),
                  ),
                ],
              ),
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
            child: SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight - 200,
              child: Column(
                children: [
                  Text(
                    'Work timer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: 220,
                    height: 120,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.ms,
                      initialTimerDuration:
                          Duration(minutes: workTimer.inMinutes, seconds: workTimer.inSeconds),
                      onTimerDurationChanged: (Duration newDuration) {
                        workTimer = newDuration;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Intermission timer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: 220,
                    height: 120,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.ms,
                      initialTimerDuration: Duration(
                          minutes: intermissionTimer.inMinutes,
                          seconds: intermissionTimer.inSeconds),
                      onTimerDurationChanged: (Duration newDuration) {
                        intermissionTimer = newDuration;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Review timer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 6),
                  SizedBox(
                    width: 200,
                    height: 100,
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.ms,
                      initialTimerDuration:
                          Duration(minutes: reviewTimer.inMinutes, seconds: reviewTimer.inSeconds),
                      onTimerDurationChanged: (Duration newDuration) {
                        reviewTimer = newDuration;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
}

Future<VotingExclusionBundle?> _showAddVotingExclusionDialog({
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
                  context.pop();
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
                  context.pop(votingExclusionBundle);
                },
                child: Text(
                  'Add',
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
