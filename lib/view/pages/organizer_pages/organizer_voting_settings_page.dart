import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/bundles/contest_details_bundle.dart';
import 'package:swift_contest/model/bundles/participation_bundle.dart';
import 'package:swift_contest/model/bundles/voting_exclusion_bundle.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/google_place_models/google_place.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/place_picker_form_field.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerVotingSettingsPage extends StatefulWidget {
  final ContestDetailsBundle contestDetailsBundle;

  const OrganizerVotingSettingsPage({required this.contestDetailsBundle, super.key});

  @override
  State<OrganizerVotingSettingsPage> createState() => _OrganizerVotingSettingsPageState();
}

class _OrganizerVotingSettingsPageState extends State<OrganizerVotingSettingsPage> {
  late User user;
  late ContestDetailsBundle contestDetailsBundle;

  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys => [firstFormKey, secondFormKey, thirdFormKey];
  int currentStep = 0;

  bool areSimpleJurorsAllowed = false;
  final List<VotingExclusionBundle> votingExclusions = [];
  Duration workTimer = Duration(minutes: 0, seconds: 10);
  Duration intermissionTimer = Duration(minutes: 0, seconds: 10);
  Duration reviewTimer = Duration(minutes: 0, seconds: 20);

  bool isGeoRestricted = false;
  final geoRestrictionPlaceController = TextEditingController();
  GooglePlace? geoRestrictionPlace;
  final geoRestrictionRadiusController = TextEditingController();
  final List<ParticipationBundle> votingParticipationsBundles = [];
  final List<JurationBundle> votingJurationsBundles = [];

  @override
  void initState() {
    super.initState();
    contestDetailsBundle = widget.contestDetailsBundle;
    votingParticipationsBundles.addAll(contestDetailsBundle.joinedParticipationsWithWorksBundles);
    votingJurationsBundles.addAll(contestDetailsBundle.joinedJurationsBundles);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = context.read<AuthBloc>().state.user!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizerVotingSettingsPageBloc>(
      create: (context) => OrganizerVotingSettingsPageBloc(
        votingFormRepository: context.read(),
        votingSessionRepository: context.read(),
        votingFormFieldRepository: context.read(),
        votingSessionParticipationRepository: context.read(),
        votingSessionJurationRepository: context.read(),
        utilsRepository: context.read(),
        placeRepository: context.read(),
        votingSessionExclusionRepository: context.read(),
        organizerRepository: context.read(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Voting settings'),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child:
                    BlocConsumer<OrganizerVotingSettingsPageBloc, OrganizerVotingSettingsPageState>(
                  listener: (context, state) {
                    if (state.status.isFailure) {
                      showSnackBar(context: context, text: state.message!);
                    }
                    if (state.status.isSuccess) {
                      context.replaceNamed(AppRouter.organizerVotingProcedure,
                          extra: state.votingSessionBundle!.toJson());
                    }
                  },
                  builder: (context, state) {
                    return Stepper(
                      type: StepperType.horizontal,
                      currentStep: currentStep,
                      onStepContinue: () {
                        final isLastStep = (currentStep == getSteps().length - 1);
                        if (formKeys[currentStep].currentState?.validate() ?? false) {
                          if (isLastStep) {
                            context
                                .read<OrganizerVotingSettingsPageBloc>()
                                .add(OrganizerVotingSettingsPageBeginVotingProcedure(
                                  contestId: contestDetailsBundle.contest.id,
                                  votingFormId: contestDetailsBundle.votingFormBundle.votingForm.id,
                                  areSimpleJurorsAllowed: areSimpleJurorsAllowed,
                                  votingExclusionsBundles: votingExclusions,
                                  votingParticipationsBundles: votingParticipationsBundles,
                                  votingJurationsBundles: votingJurationsBundles,
                                  workTimer: workTimer,
                                  intermissionTimer: intermissionTimer,
                                  reviewTimer: reviewTimer,
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
                                child: isLastStep
                                    ? BlocConsumer<OrganizerVotingSettingsPageBloc,
                                        OrganizerVotingSettingsPageState>(
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          if (state.status.isLoading) {
                                            return Loader();
                                          }
                                          return Text('Start');
                                        },
                                      )
                                    : Text('Next'),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: getSteps(),
                    );
                  },
                ),
              );
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
          title: Text(
            '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 0)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: firstFormKey,
            child: SizedBox(
              height: 400,
              child: ListView(
                children: [
                  Text('Geo restriction'),
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
                  PlacePickerFormField(
                    enabled: isGeoRestricted,
                    controller: geoRestrictionPlaceController,
                    label: 'Restricted location',
                    validator: (isGeoRestricted) ? (value) => locationValidator(value) : null,
                    onSelected: (placeValue) => geoRestrictionPlace = placeValue,
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                  CustomTextFormFieldOutlined(
                    enabled: isGeoRestricted,
                    controller: geoRestrictionRadiusController,
                    label: 'Restriction radius',
                  ),
                  SizedBox(
                    height: 200,
                    child: ReorderableListView(
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (oldIndex < newIndex) {
                            newIndex -= 1;
                          }
                          final ParticipationBundle ppw =
                              votingParticipationsBundles.removeAt(oldIndex);
                          votingParticipationsBundles.insert(newIndex, ppw);
                        });
                      },
                      children: [
                        for (var i = 0; i < votingParticipationsBundles.length; i++)
                          ListTile(
                            key: ValueKey(votingParticipationsBundles[i].participation.id),
                            title: Column(
                              children: [
                                Text(votingParticipationsBundles[i].work!.name),
                                Text(votingParticipationsBundles[i].participant.fullName),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //* Second step
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text(
            '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 1)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: secondFormKey,
            child: SizedBox(
              height: 400,
              child: ListView(
                children: [
                  Text('Who can vote'),
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
                  Text('Voting exclusions'),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: votingExclusions.length + 1,
                      itemBuilder: (context, index) {
                        if (index != votingExclusions.length) {
                          return ListTile(
                            title: Column(
                              children: [
                                Row(
                                  children: [
                                    Text('Juror: '),
                                    Text(votingExclusions[index].jurationBundle.juror.fullName),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('Participant: '),
                                    Text(votingExclusions[index]
                                        .participationBundle
                                        .participant
                                        .fullName),
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else {
                          return FilledButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  ParticipationBundle? chosenParticipationBundle;
                                  JurationBundle? chosenJurationBundle;
                                  return AlertDialog(
                                    title: Text('Exclusion'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Participant'),
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
                                            for (var element in votingParticipationsBundles)
                                              DropdownMenuEntry(
                                                  value: element,
                                                  label: element.participant.fullName),
                                          ],
                                        ),
                                        Text('Juror'),
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
                                            for (var element in votingJurationsBundles)
                                              DropdownMenuEntry(
                                                value: element,
                                                label: element.juror.fullName,
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              context.pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              if (chosenParticipationBundle == null ||
                                                  chosenJurationBundle == null) {
                                                showSnackBar(
                                                    context: context, text: 'Fill all the fields');
                                                return;
                                              }
                                              final votingExclusionBundle = VotingExclusionBundle(
                                                participationBundle: chosenParticipationBundle!,
                                                jurationBundle: chosenJurationBundle!,
                                              );
                                              if (votingExclusions
                                                  .contains(votingExclusionBundle)) {
                                                showSnackBar(
                                                    context: context,
                                                    text: 'Exclusion already added');
                                                return;
                                              }
                                              setState(() {
                                                votingExclusions.add(votingExclusionBundle);
                                              });
                                              context.pop();
                                            },
                                            child: Text('Add'),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Add'),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        //* Third step
        Step(
          state: currentStep >= 3 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text(
            '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 2)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: thirdFormKey,
            child: SizedBox(
              height: 400,
              child: ListView(
                children: [
                  // Text('Voting type'),
                  // RadioListTile<VotingType>.adaptive(
                  //   title: Text('Free'),
                  //   value: VotingType.free,
                  //   groupValue: votingType,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       votingType = value!;
                  //       reviewType = ReviewType.absent;
                  //     });
                  //   },
                  // ),
                  // RadioListTile<VotingType>.adaptive(
                  //   title: Text('Timed'),
                  //   value: VotingType.timed,
                  //   groupValue: votingType,
                  //   onChanged: (value) {
                  //     setState(() {
                  //       votingType = value!;
                  //     });
                  //   },
                  // ),
                  // (votingType == VotingType.timed)
                  //     ? Column(
                  //         children: [
                  //           Text('Review'),
                  //           RadioListTile<ReviewType>.adaptive(
                  //             title: Text('Absent'),
                  //             value: ReviewType.absent,
                  //             groupValue: reviewType,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 reviewType = ReviewType.absent;
                  //               });
                  //             },
                  //           ),
                  //           RadioListTile<ReviewType>.adaptive(
                  //             title: Text('Timed'),
                  //             value: ReviewType.timed,
                  //             groupValue: reviewType,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 reviewType = ReviewType.timed;
                  //               });
                  //             },
                  //           ),
                  //         ],
                  //       )
                  //     : SizedBox.shrink(),
                  // if (votingType == VotingType.timed)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Work timer'),
                      CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration:
                            Duration(minutes: workTimer.inMinutes, seconds: workTimer.inSeconds),
                        onTimerDurationChanged: (Duration newDuration) {
                          workTimer = newDuration;
                        },
                      ),
                      Text('Intermission timer'),
                      CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration: Duration(
                            minutes: intermissionTimer.inMinutes,
                            seconds: intermissionTimer.inSeconds),
                        onTimerDurationChanged: (Duration newDuration) {
                          intermissionTimer = newDuration;
                        },
                      ),
                      Text('Review timer'),
                      CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        initialTimerDuration: Duration(
                            minutes: reviewTimer.inMinutes, seconds: reviewTimer.inSeconds),
                        onTimerDurationChanged: (Duration newDuration) {
                          reviewTimer = newDuration;
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ];
}

String? locationValidator(String? value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return null;
}
