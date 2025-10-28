import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/voting_form_submission_value_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_juror_voting_results_page_bloc/organizer_juror_voting_results_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerJurorVotingResultsPage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionJurorId;

  const OrganizerJurorVotingResultsPage({
    @PathParam('votingSessionJurorId') required this.votingSessionJurorId,
    super.key,
  });

  @override
  State<OrganizerJurorVotingResultsPage> createState() => _OrganizerJurorVotingResultsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<OrganizerJurorVotingResultsPageBloc>(
      create: (context) => OrganizerJurorVotingResultsPageBloc(
        organizerRepository: context.read(),
      )..add(OrganizerJurorVotingResultsPageFetch(votingSessionJurorId: votingSessionJurorId)),
      child: this,
    );
  }
}

class _OrganizerJurorVotingResultsPageState extends State<OrganizerJurorVotingResultsPage> {
  late String votingSessionJurorId;
  VotingSessionParticipant? chosenVotingSessionParticipant;

  @override
  void initState() {
    super.initState();
    votingSessionJurorId = widget.votingSessionJurorId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJurorVotingResultsPageBloc, OrganizerJurorVotingResultsPageState>(
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
          appBar: CustomAppBar(
              title: state.votingSessionJurorResultBundle?.votingFormSubmissionBundle
                      .votingSessionJuror.jurorFullName ??
                  ''),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context
                              .read<OrganizerJurorVotingResultsPageBloc>()
                              .add(OrganizerJurorVotingResultsPageFetch(
                                  votingSessionJurorId: votingSessionJurorId)),
                          child: const Text('Retry'),
                        ),
                      );
                    }
                    return const VoidWidget();
                  }

                  final votingFormBundle = state.votingSessionJurorResultBundle!.votingFormBundle;
                  int tabsCount = 0;
                  if (votingFormBundle.headerVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }
                  if (votingFormBundle.participantVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }
                  if (votingFormBundle.footerVotingFormFields.isNotEmpty) {
                    ++tabsCount;
                  }

                  if (tabsCount == 0) {
                    return const Center(
                      child: Text(
                        'No field was added to the form\nfor this jury',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return DefaultTabController(
                    length: tabsCount,
                    child: Column(
                      children: [
                        TabBar(
                          tabs: [
                            if (votingFormBundle.headerVotingFormFields.isNotEmpty)
                              const Tab(text: 'Header'),
                            if (votingFormBundle.participantVotingFormFields.isNotEmpty)
                              const Tab(text: 'Participants'),
                            if (votingFormBundle.footerVotingFormFields.isNotEmpty)
                              const Tab(text: 'Footer'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: TabBarView(children: [
                            if (votingFormBundle.headerVotingFormFields.isNotEmpty)
                              _buildHeaderTab(context, state),
                            if (votingFormBundle.participantVotingFormFields.isNotEmpty)
                              _buildParticipantsTab(context, state),
                            if (votingFormBundle.footerVotingFormFields.isNotEmpty)
                              _buildFooterTab(context, state),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final headerValues = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .headerVotingFormSubmissionValuesBundles;
    final headerFields =
        state.votingSessionJurorResultBundle!.votingFormBundle.headerVotingFormFields;
    return ListView.builder(
      itemCount: headerFields.length,
      itemBuilder: (context, index) {
        final headerField = headerFields[index];
        final headerValue =
            headerValues.where((e) => e.votingFormField == headerField).singleOrNull;
        final requiredSymbol = headerField.isRequired ? '*' : '';
        final sliderRange = headerField.type.isSlider
            ? '[${headerField.sliderMinValue}-${headerField.sliderMaxValue}]'
            : '';
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: headerField.question, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                    const TextSpan(text: ' '),
                    TextSpan(text: '$sliderRange $requiredSymbol', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                  ],
                ),
              ),
              Text((headerValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                  ? headerValue!.votingFormSubmissionValue.value
                  : 'No answer')
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooterTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final footerValues = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .footerVotingFormSubmissionValuesBundles;
    final footerFields =
        state.votingSessionJurorResultBundle!.votingFormBundle.footerVotingFormFields;
    return ListView.builder(
      itemCount: footerFields.length,
      itemBuilder: (context, index) {
        final footerField = footerFields[index];
        final footerValue =
            footerValues.where((e) => e.votingFormField == footerField).singleOrNull;
        final requiredSymbol = footerField.isRequired ? '*' : '';
        final sliderRange = footerField.type.isSlider
            ? '[${footerField.sliderMinValue}-${footerField.sliderMaxValue}]'
            : '';
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: footerField.question, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                    const TextSpan(text: ' '),
                    TextSpan(text: '$sliderRange $requiredSymbol', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                  ],
                ),
              ),
              Text((footerValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                  ? footerValue!.votingFormSubmissionValue.value
                  : 'No answer')
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantsTab(
    BuildContext context,
    OrganizerJurorVotingResultsPageState state,
  ) {
    final votingSessionParticipants =
        state.votingSessionJurorResultBundle!.votingSessionParticipants;
    final participantsValuesMap = state.votingSessionJurorResultBundle!.votingFormSubmissionBundle
        .participantVotingFormSubmissionValuesBundles;
    final excludedVotingSessionParticipantsIds =
        state.votingSessionJurorResultBundle!.excludedVotingSessionParticipantsIds;
    List<VotingFormSubmissionValueBundle>? participantValues =
        participantsValuesMap[chosenVotingSessionParticipant];
    final participantFields =
        state.votingSessionJurorResultBundle!.votingFormBundle.participantVotingFormFields;

    return ListView(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownMenu(
          label: const Text('Participant'),
          onSelected: (value) {
            setState(() {
              chosenVotingSessionParticipant = value!;
            });
          },
          initialSelection: chosenVotingSessionParticipant,
          dropdownMenuEntries: [
            ...votingSessionParticipants.map((votingSessionParticipant) {
              return DropdownMenuEntry(
                value: votingSessionParticipant,
                label: votingSessionParticipant.participantFullName,
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        if (chosenVotingSessionParticipant == null)
          const Text('Select a participant')
        else if (excludedVotingSessionParticipantsIds.contains(chosenVotingSessionParticipant?.id!))
          const Text('Excluded from voting this participant')
        else
          ...participantFields.map((participantField) {
            final participantValue = participantValues?.where((e) => e.votingFormField == participantField).singleOrNull;
            final requiredSymbol = participantField.isRequired ? '*' : '';
            final sliderRange = participantField.type.isSlider
                ? '[${participantField.sliderMinValue}-${participantField.sliderMaxValue}]'
                : '';
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: participantField.question, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                        const TextSpan(text: ' '),
                        TextSpan(text: '$sliderRange $requiredSymbol', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.teal)),
                      ],
                    ),
                  ),
                  Text((participantValue?.votingFormSubmissionValue.value.isNotEmpty ?? false)
                      ? participantValue!.votingFormSubmissionValue.value
                      : 'No answer', style: Theme.of(context).textTheme.bodyLarge,)
                ],
              ),
            );
          }),
        const SizedBox(height: 72),
      ],
    );
  }
}
