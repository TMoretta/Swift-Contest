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
          appBar: const CustomAppBar(title: 'Voting settings'),
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
                        child: const Text('Retry'),
                      ),
                    );
                  }
                  return const VoidWidget();
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
                      margin: const EdgeInsets.only(top: 64),
                      child: Row(
                        mainAxisAlignment: (currentStep == 0)
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.spaceBetween,
                        spacing: 12,
                        children: [
                          if (details.currentStep != 0)
                            ElevatedButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Back'),
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
          title: const Text(''),
          content: Form(
            key: firstFormKey,
            child: FormField<List<ParticipationBundle>>(
              initialValue: participationsBundles,
              validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
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
                        ? AbsorbPointer(
                            absorbing: participationsBundles.length == 1,
                            child: ReorderableListView(
                              shrinkWrap: true,
                              onReorder: (oldIndex, newIndex) {
                                if (participationsBundles.length == 1) return;
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
                                      title: Text(participationsBundles[i].participantBundle.profile.fullName),
                                      subtitle: Text(participationsBundles[i].work!.name),
                                      leading: const Icon(Icons.swap_vert),
                                      trailing: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            votingExclusions.removeWhere(
                                              (e) =>
                                                  e.participationBundle == participationsBundles[i],
                                            );
                                            field.didChange(participationsBundles);
                                            excludedParticipationsBundles
                                                .add(participationsBundles[i]);
                                            participationsBundles.removeAt(i);
                                          });
                                        },
                                        icon: const Icon(Icons.remove),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('No participant included'),
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
                    const SizedBox(height: 64),
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
                                  title: Text(excludedParticipationBundle.participantBundle.profile.fullName),
                                  subtitle: Text(excludedParticipationBundle.work!.name),
                                  trailing: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        field.didChange(participationsBundles);
                                        participationsBundles.add(excludedParticipationBundle);
                                        excludedParticipationsBundles.removeAt(index);
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Text('No participant excluded'),
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
          title: const Text(''),
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
                  child: const Column(
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
                const SizedBox(height: 32),
                PlacePickerFormField(
                  controller: geoRestrictionPlaceController,
                  focusNode: geoRestrictionPlaceFocusNode,
                  label: 'Restricted location',
                  validator: (isGeoRestricted) ? noEmptyValidator : null,
                  prefixIcon: const Icon(Icons.place_outlined),
                  enabled: isGeoRestricted,
                  suffixIcon: TextButton(
                    onPressed: (isGeoRestricted)
                        ? () async {
                            geoRestrictionPlaceFocusNode.requestFocus();
                            final Place? place = await context.router.push(const PlaceSearchRoute());
                            if (place != null) {
                              geoRestrictionPlaceController.text = place.address;
                              geoRestrictionPlace = place;
                            }
                          }
                        : null,
                    child: const Text('Select'),
                  ),
                ),
                const SizedBox(height: 6),
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
          title: const Text(''),
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
                const SizedBox(height: 4),
                (votingExclusions.isNotEmpty)
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: votingExclusions.length,
                        itemBuilder: (context, index) {
                          final votingExclusion = votingExclusions[index];
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Jur: ',
                                        style: Theme.of(context).textTheme.labelLarge),
                                    TextSpan(
                                      text: votingExclusion.jurationBundle.jurorBundle.profile.fullName,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    TextSpan(
                                        text: ' | ', style: Theme.of(context).textTheme.labelLarge),
                                    TextSpan(
                                      text: juriesBundles
                                          .map((e) => e.jury)
                                          .where((e) =>
                                              votingExclusion.jurationBundle.juration.juryId ==
                                              e.id)
                                          .first
                                          .name,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: RichText(
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'Par: ',
                                        style: Theme.of(context).textTheme.labelLarge),
                                    TextSpan(
                                      text:
                                          votingExclusion.participationBundle.participantBundle.profile.fullName,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    TextSpan(
                                        text: ' | ', style: Theme.of(context).textTheme.labelLarge),
                                    TextSpan(
                                      text: votingExclusion.participationBundle.work!.name,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      votingExclusions.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.remove)),
                            ),
                          );
                        },
                      )
                    : const Text('No exclusion added'),
                const SizedBox(height: 12),
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
            title: const Text('Exclusion'),
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
                            '${element.jurorBundle.profile.fullName} | ${juries.where((e) => e.id == element.juration.juryId).first.name}',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      DropdownMenuEntry(
                        value: element,
                        label: '${element.participantBundle.profile.fullName} | ${element.work!.name}',
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
                child: const Text('Cancel'),
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
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    },
  );
}
