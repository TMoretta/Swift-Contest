import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/data_models/juration/juration.dart';
import 'package:swift_contest/model/data_models/juration/juration_status.dart';
import 'package:swift_contest/model/data_models/participation/participation.dart';
import 'package:swift_contest/model/data_models/participation/participation_status.dart';
import 'package:swift_contest/model/data_models/profile/profile.dart';
import 'package:swift_contest/model/data_models/user/user.dart';
import 'package:swift_contest/model/data_models/voting/review_type.dart';
import 'package:swift_contest/model/data_models/voting/voting_type.dart';
import 'package:swift_contest/model/data_models/work/work.dart';
import 'package:swift_contest/model/mixed_models/juration_and_juror.dart';
import 'package:swift_contest/model/mixed_models/participant_and_juror.dart';
import 'package:swift_contest/model/mixed_models/participation_and_participant.dart';
import 'package:swift_contest/model/mixed_models/participation_and_participant_and_work.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/data_transfer_bloc/data_transfer_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_voting_settings_page_bloc/organizer_voting_settings_page_bloc.dart';

class OrganizerVotingSettingsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const OrganizerVotingSettingsPage({super.key, required this.data});

  @override
  State<OrganizerVotingSettingsPage> createState() => _OrganizerVotingSettingsPageState();
}

class _OrganizerVotingSettingsPageState extends State<OrganizerVotingSettingsPage> {
  late User user;
  late Map<String, dynamic> data;
  final List<ParticipationAndParticipantAndWork> joinedParticipationsAndParticipantsWithWorks = [];
  final List<ParticipationAndParticipant> joinedParticipationsAndParticipantsWithoutWorks = [];
  final List<JurationAndJuror> joinedJurationsAndJurors = [];

  final firstFormKey = GlobalKey<FormState>();
  final secondFormKey = GlobalKey<FormState>();
  final thirdFormKey = GlobalKey<FormState>();
  final fourthFormKey = GlobalKey<FormState>();

  List<GlobalKey<FormState>> get formKeys =>
      [firstFormKey, secondFormKey, thirdFormKey, fourthFormKey];
  int currentStep = 0;

  VotingType votingType = VotingType.notTimed;
  ReviewType reviewType = ReviewType.absent;
  bool isNonInvitedJurorVotingAllowed = false;
  final List<ParticipantAndJuror> votingExclusions = [];

  @override
  void initState() {
    super.initState();
    user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    data = widget.data;

    // final data = (context.read<DataTransferBloc>().state as DataTransferSuccess).data;

    final participations = data['participations']!
        .map((json) => Participation.fromJson(json!))
        .toList(growable: false);

    final participants = data['participants']!
        .map((json) => json != null ? Profile.fromJson(json) : null)
        .toList(growable: false);

    final works = data['works']!
        .map((json) => json != null ? Work.fromJson(json) : null)
        .toList(growable: false);

    final jurations = data['jurations']!
        .map((json) => Juration.fromJson(json!))
        .toList(growable: false);

    final jurors = data['jurors']!
        .map((json) => json != null ? Profile.fromJson(json) : null)
        .toList(growable: false);

    // final contestDetailsState = context.read<OrganizerContestDetailsPageBloc>().state;
    // final participations = contestDetailsState.participations!;
    // final participants = contestDetailsState.participants!;
    // final works = contestDetailsState.works!;
    // final jurations = contestDetailsState.jurations!;
    // final jurors = contestDetailsState.jurors!;

    for (var i = 0; i < participations.length; i++) {
      if (participations[i].status == ParticipationStatus.joined) {
        if (works[i] != null) {
          final ppw = ParticipationAndParticipantAndWork(
            participation: participations[i],
            participant: participants[i],
            work: works[i],
          );
          joinedParticipationsAndParticipantsWithWorks.add(ppw);
        } else {
          final pp = ParticipationAndParticipant(
            participation: participations[i],
            participant: participants[i],
          );
          joinedParticipationsAndParticipantsWithoutWorks.add(pp);
        }
      }
    }
    for (var i = 0; i < jurations.length; i++) {
      if (jurations[i].status == JurationStatus.joined) {
        final jj = JurationAndJuror(
          juration: jurations[i],
          juror: jurors[i],
        );
        joinedJurationsAndJurors.add(jj);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrganizerVotingSettingsPageBloc>(
      create: (context) => OrganizerVotingSettingsPageBloc(),
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
                child: Stepper(
                  type: StepperType.horizontal,
                  physics: ScrollPhysics(),
                  currentStep: currentStep,
                  onStepContinue: () {
                    final isLastStep = (currentStep == getSteps().length - 1);
                    if (formKeys[currentStep].currentState?.validate() ?? false) {
                      if (isLastStep) {
                        //   final name = nameController.text;
                        //   final description = descriptionController.text;
                        //   final dateTime =
                        //   DateTime(date!.year, date!.month, date!.day, time!.hour, time!.minute);
                        //   context.read<OrganizerContestCreationPageBloc>().add(
                        //     OrganizerContestCreationPageCreateContest(
                        //       name: name,
                        //       description: description,
                        //       organizerId: user.id,
                        //       place:
                        //       Place(address: place!.address, lat: place!.lat, lon: place!.lon),
                        //       worksPreviewJurors: worksPreviewJurors,
                        //       dateTime: dateTime,
                        //       worksDateTimeFrom: worksDateTimeFrom!,
                        //       worksDateTimeTo: worksDateTimeTo!,
                        //       images: images,
                        //     ),
                        //   );
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
                            child: (isLastStep) ? Text('Start') : Text('Next'),
                            // isLastStep
                            //     ? BlocConsumer<OrganizerContestCreationPageBloc, OrganizerContestCreationPageState>(
                            //   listener: (context, state) {
                            //     if (state is OrganizerContestCreationPageSuccess) {
                            //       showSnackBar(
                            //           context: context, text: 'Contest created successfully');
                            //       context.pop(true);
                            //     }
                            //   },
                            //   builder: (context, state) {
                            //     if (state is OrganizerContestCreationPageLoading) {
                            //       return Loader();
                            //     }
                            //     return Text('Create');
                            //   },
                            // )
                            //     : Text('Next'),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: getSteps(),
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
            child: Column(
              children: [
                ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final ParticipationAndParticipantAndWork ppw =
                          joinedParticipationsAndParticipantsWithWorks.removeAt(oldIndex);
                      joinedParticipationsAndParticipantsWithWorks.insert(newIndex, ppw);
                    });
                  },
                  children: [
                    for (var i = 0; i < joinedParticipationsAndParticipantsWithWorks.length; i++)
                      ListTile(
                        title: Column(
                          children: [
                            Text(joinedParticipationsAndParticipantsWithWorks[i].work!.name),
                            Text(
                                '${joinedParticipationsAndParticipantsWithWorks[i].participant!.firstName} '
                                '${joinedParticipationsAndParticipantsWithWorks[i].participant!.lastName}'),
                          ],
                        ),
                      ),
                  ],
                ),
                if (joinedParticipationsAndParticipantsWithoutWorks.isNotEmpty)
                  Column(
                    children: [
                      Text('Note: there are some participants that not submitted a work'),
                      ListView.builder(
                        itemCount: joinedParticipationsAndParticipantsWithoutWorks.length,
                        shrinkWrap: true, // opzionale ma utile in questo contesto
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                '${joinedParticipationsAndParticipantsWithoutWorks[index].participant!.firstName} '
                                '${joinedParticipationsAndParticipantsWithoutWorks[index].participant!.lastName}'),
                          );
                        },
                      ),
                    ],
                  ),
              ],
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
            child: ListView(
              children: [
                Text('Who can vote'),
                RadioListTile<bool>.adaptive(
                  title: Text('Only invited jurors'),
                  value: false,
                  groupValue: isNonInvitedJurorVotingAllowed,
                  onChanged: (value) {
                    setState(() {
                      isNonInvitedJurorVotingAllowed = value!;
                    });
                  },
                ),
                RadioListTile<bool>.adaptive(
                  title: Text('Anyone with contest identifier'),
                  value: true,
                  groupValue: isNonInvitedJurorVotingAllowed,
                  onChanged: (value) {
                    setState(() {
                      isNonInvitedJurorVotingAllowed = value!;
                    });
                  },
                ),
                Text('Voting exclusions'),
                ListView.builder(
                  itemCount: votingExclusions.length + 1,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Column(
                        children: [
                          Row(
                            children: [
                              Text('Juror: '),
                              Text('${votingExclusions[index].juror.firstName} '
                                  '${votingExclusions[index].juror.lastName}'),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Participant: '),
                              Text('${votingExclusions[index].participant.firstName} '
                                  '${votingExclusions[index].participant.lastName}'),
                            ],
                          ),
                          if (index == votingExclusions.length)
                            FilledButton(
                              onPressed: () {
                                //todo aggiungere dialog per esclusioni
                              },
                              child: Text('Add'),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
            child: ListView(
              children: [
                Text('Voting type'),
                RadioListTile<VotingType>.adaptive(
                  title: Text('Not timed'),
                  value: VotingType.notTimed,
                  groupValue: votingType,
                  onChanged: (value) {
                    setState(() {
                      votingType = value!;
                      reviewType = ReviewType.absent;
                    });
                  },
                ),
                RadioListTile<VotingType>.adaptive(
                  title: Text('Timed'),
                  value: VotingType.timed,
                  groupValue: votingType,
                  onChanged: (value) {
                    setState(() {
                      votingType = value!;
                    });
                  },
                ),
                (votingType == VotingType.timed)
                    ? Column(
                        children: [
                          Text('Review'),
                          RadioListTile<ReviewType>.adaptive(
                            title: Text('Absent'),
                            value: ReviewType.absent,
                            groupValue: reviewType,
                            onChanged: (value) {
                              setState(() {
                                reviewType = ReviewType.absent;
                              });
                            },
                          ),
                          RadioListTile<ReviewType>.adaptive(
                            title: Text('Timed'),
                            value: ReviewType.timed,
                            groupValue: reviewType,
                            onChanged: (value) {
                              setState(() {
                                reviewType = ReviewType.timed;
                              });
                            },
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
        //* Fourth step
        Step(
          state: currentStep >= 4 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 3,
          title: Text(
            '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: (currentStep == 3)
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.grey9,
            ),
          ),
          content: Form(
            key: fourthFormKey,
            child: Placeholder(),
          ),
        ),
      ];
}
