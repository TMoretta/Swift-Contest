import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/bundles/juror_voting_session_procedure_bundle.dart';
import 'package:swift_contest/model/database/entities/voting_form.dart';
import 'package:swift_contest/model/database/entities/voting_form_field.dart';
import 'package:swift_contest/model/database/entities/voting_session_participant.dart';
import 'package:swift_contest/model/database/types/storage_bucket.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/model/database/types/voting_session_status.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_slider_form_field.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/images_carousel_full_screen.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/storage_image.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/juror_voting_procedure_page_bloc/juror_voting_procedure_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class JurorVotingProcedurePage extends StatefulWidget implements AutoRouteWrapper {
  final String votingSessionId;

  const JurorVotingProcedurePage({
    @PathParam('votingSessionId') required this.votingSessionId,
    super.key,
  });

  @override
  State<JurorVotingProcedurePage> createState() => _JurorVotingProcedurePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<JurorVotingProcedurePageBloc>(
      create: (context) => JurorVotingProcedurePageBloc(
        jurorRepository: context.read(),
      )..add(JurorVotingProcedurePageFetch(votingSessionId: votingSessionId)),
      child: this,
    );
  }
}

class _JurorVotingProcedurePageState extends State<JurorVotingProcedurePage> {
  final formKey = GlobalKey<FormState>();
  final Map<VotingFormField, TextEditingController> _headerFieldsValuesMap = {};
  final Map<VotingFormField, FocusNode> _headerFieldsFocusNodes = {};
  final Map<VotingFormField, TextEditingController> _footerFieldsValuesMap = {};
  final Map<VotingFormField, FocusNode> _footerFieldsFocusNodes = {};
  final Map<VotingSessionParticipant, Map<VotingFormField, TextEditingController>>
      _participantFieldsValuesMap = {};
  final Map<VotingSessionParticipant, Map<VotingFormField, FocusNode>>
      _participantFieldsFocusNodes = {};
  bool isPageInitialized = false;
  int pageIndex = 0;
  final _pageController = PageController(initialPage: 0);
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    context.hideLoader();
    _headerFieldsValuesMap.forEach((_, controller) => controller.dispose());
    _headerFieldsFocusNodes.forEach((_, node) => node.dispose());
    _footerFieldsValuesMap.forEach((_, controller) => controller.dispose());
    _footerFieldsFocusNodes.forEach((_, node) => node.dispose());
    _participantFieldsValuesMap.forEach((_, controllerMap) {
      controllerMap.forEach((_, controller) {
        controller.dispose();
      });
    });
    _participantFieldsFocusNodes.forEach((_, focusNodeMap) {
      focusNodeMap.forEach((_, node) {
        node.dispose();
      });
    });
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JurorVotingProcedurePageBloc, JurorVotingProcedurePageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
        if (state.status.isLoading) {
          context.showLoader();
        } else {
          context.hideLoader();
        }
        if (state.isInitialized) {
          if (state.votingSessionProcedureBundle?.votingSessionBundle.votingSession.sessionStatus
                  .isEnded ??
              false) {
            if (!isFinished) {
              isFinished = true;

              showSnackBar(context: context, text: 'Voting session procedure is ended');
              context.router.pop(true);
            }
          }
          if (state.votingSessionProcedureBundle?.votingSessionBundle.votingSession.sessionStatus
                  .isCancelled ??
              false) {
            if (!isFinished) {
              isFinished = true;
              showSnackBar(context: context, text: 'Voting session procedure has been cancelled');
              context.router.pop(true);
            }
          }
        }
        if (state.status.isSuccess && state.sourceEvent is JurorVotingProcedurePageSubmit) {
          showSnackBar(context: context, text: 'Votes submitted successfully');
          context.router.pop();
        }
      },
      builder: (context, state) {
        if (!state.isInitialized) {
          if (state.status.isFailure) {
            return Center(
              child: FilledButton(
                onPressed: () async => context
                    .read<JurorVotingProcedurePageBloc>()
                    .add(JurorVotingProcedurePageFetch(votingSessionId: widget.votingSessionId)),
                child: Text('Retry'),
              ),
            );
          }
          return VoidWidget();
        }
        return Scaffold(
          appBar: CustomAppBar(title: 'Voting'),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async => context.read<JurorVotingProcedurePageBloc>().add(
                              JurorVotingProcedurePageFetch(
                                  votingSessionId: widget.votingSessionId)),
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  final votingSessionProcedureBundle = state.votingSessionProcedureBundle!;
                  final votingSessionParticipants =
                      votingSessionProcedureBundle.votingSessionParticipants;
                  final votingForm = votingSessionProcedureBundle.votingFormBundle.votingForm;
                  final headerVotingFormFields =
                      votingSessionProcedureBundle.votingFormBundle.headerVotingFormFields;
                  final participantVotingFormFields =
                      votingSessionProcedureBundle.votingFormBundle.participantVotingFormFields;
                  final footerVotingFormFields =
                      votingSessionProcedureBundle.votingFormBundle.footerVotingFormFields;

                  if (!isPageInitialized) {
                    for (var participant in votingSessionParticipants) {
                      final Map<VotingFormField, TextEditingController> fieldsControllers = {};
                      final Map<VotingFormField, FocusNode> fieldsFocusNodes = {};
                      for (var votingFormField in participantVotingFormFields) {
                        fieldsControllers[votingFormField] = TextEditingController();
                        fieldsFocusNodes[votingFormField] = FocusNode();
                      }
                      _participantFieldsValuesMap[participant] = fieldsControllers;
                      _participantFieldsFocusNodes[participant] = fieldsFocusNodes;
                    }
                    for (var field in headerVotingFormFields) {
                      _headerFieldsValuesMap[field] = TextEditingController();
                      _headerFieldsFocusNodes[field] = FocusNode();
                    }
                    for (var field in footerVotingFormFields) {
                      _footerFieldsValuesMap[field] = TextEditingController();
                      _footerFieldsFocusNodes[field] = FocusNode();
                    }
                    isPageInitialized = true;
                  }

                  final List<Widget> pages = [];
                  pages.add(_KeepAlivePage(child: _buildIntroductionPage(context, votingForm)));

                  if (headerVotingFormFields.isNotEmpty) {
                    pages.add(_KeepAlivePage(
                        child: _buildHeaderFormPage(context, headerVotingFormFields)));
                  }
                  if (participantVotingFormFields.isNotEmpty) {
                    pages.addAll(votingSessionParticipants.map((p) => _KeepAlivePage(
                        child: _buildParticipantFormPage(context, p, participantVotingFormFields,
                            votingSessionProcedureBundle))));
                  }
                  if (footerVotingFormFields.isNotEmpty) {
                    pages.add(_KeepAlivePage(
                        child: _buildFooterFormPage(context, footerVotingFormFields)));
                  }

                  return Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView(
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _pageController,
                            onPageChanged: (value) {
                              setState(() {
                                pageIndex = value;
                              });
                            },
                            children: pages,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (pageIndex != 0)
                              FilledButton(
                                onPressed: () => _pageController.previousPage(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.ease),
                                child: const Text('Previous'),
                              )
                            else
                              Visibility(
                                visible: false,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: FilledButton(
                                  onPressed: null,
                                  child: Text('Previous'),
                                ),
                              ),
                            if (votingSessionProcedureBundle
                                .votingSessionBundle.votingSession.isGeoRestricted)
                              FilledButton(
                                onPressed: () {
                                  context
                                      .read<JurorVotingProcedurePageBloc>()
                                      .add(JurorVotingProcedurePageCheckVotingLocation());
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                                child: Text(
                                  'Verify\n Location',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            FilledButton(
                              onPressed: () async {
                                final isLastPage = pageIndex == pages.length - 1;
                                if (isLastPage) {
                                  if (formKey.currentState?.validate() ?? false) {
                                    final bool? res = await showDialog(
                                      context: context,
                                      builder: (_) {
                                        return AlertDialog(
                                          title: Text('Submit'),
                                          content: Text('Are you sure you want to submit?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => context.router.pop(),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => context.router.pop(true),
                                              child: Text('Confirm'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (!context.mounted || res != true) return;

                                    // Costruisce le mappe dei voti leggendo dai controller
                                    final headerFieldsValues = _headerFieldsValuesMap
                                        .map((key, value) => MapEntry(key, value.text));
                                    final footerFieldsValues = _footerFieldsValuesMap
                                        .map((key, value) => MapEntry(key, value.text));
                                    final participantFieldsValues = _participantFieldsValuesMap.map(
                                      (participant, controllerMap) => MapEntry(
                                        participant,
                                        controllerMap.map(
                                          (field, controller) => MapEntry(field, controller.text),
                                        ),
                                      ),
                                    );

                                    if(headerFieldsValues.isEmpty && participantFieldsValues.isEmpty && footerFieldsValues.isEmpty) {
                                      showSnackBar(context: context, text: 'Please fill at least one field');
                                    }

                                    // Invia l'evento al BLoC
                                    context.read<JurorVotingProcedurePageBloc>().add(
                                          JurorVotingProcedurePageSubmit(
                                            headerFieldsValues: headerFieldsValues,
                                            participantFieldsValues: participantFieldsValues,
                                            footerFieldsValues: footerFieldsValues,
                                          ),
                                        );
                                  } else {
                                    showSnackBar(
                                        context: context, text: 'Please fill all required fields');
                                  }
                                } else {
                                  _pageController.nextPage(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.ease);
                                }
                              },
                              style: (pageIndex == pages.length - 1)
                                  ? FilledButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.tertiaryContainer,
                                      foregroundColor:
                                          Theme.of(context).colorScheme.onTertiaryContainer)
                                  : null,
                              child: Text((pageIndex == pages.length - 1) ? 'Submit' : 'Next'),
                            ),
                          ],
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

  Widget _buildIntroductionPage(BuildContext context, VotingForm votingForm) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Text(
          votingForm.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          votingForm.description,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildHeaderFormPage(BuildContext context, List<VotingFormField> headerVotingFormFields) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Text('General Evaluation', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        ...headerVotingFormFields.map((field) {
          return _buildFormField(context, field, _headerFieldsValuesMap[field]!,
              _headerFieldsFocusNodes[field]!, false);
        }),
      ],
    );
  }

  Widget _buildParticipantFormPage(
    BuildContext context,
    VotingSessionParticipant votingSessionParticipant,
    List<VotingFormField> participantVotingFormFields,
    JurorVotingSessionProcedureBundle bundle,
  ) {
    final isExcluded =
        bundle.votingSessionParticipantsExclusionsIds.contains(votingSessionParticipant.id);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //* Title
            Text(
              votingSessionParticipant.workName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 8),
            //* Images carousel
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: votingSessionParticipant.workImagesPaths.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: (votingSessionParticipant.workImagesPaths.isNotEmpty)
                        ? GestureDetector(
                            onTap: () {
                              // Show the full-screen image viewer dialog
                              showDialog(
                                context: context,
                                // Use a custom dialog for a better full-screen experience
                                builder: (_) => ImagesCarouselFullScreen(
                                  bucket: StorageBucket.worksImages,
                                  imagePaths: votingSessionParticipant.workImagesPaths,
                                  initialIndex: index,
                                ),
                              );
                            },
                            child: StorageImage(
                              bucket: StorageBucket.worksImages,
                              path: votingSessionParticipant.workImagesPaths[index],
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(Icons.broken_image_outlined),
                  );
                },
              ),
            ),
            SizedBox(height: 8),
            //* Description
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            Text(votingSessionParticipant.workDescription, style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            //* Participant name
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Icon(
                  Icons.person_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    votingSessionParticipant.participantFullName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Divider(height: 24),
        (isExcluded)
            ? Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'You are excluded from voting this participant',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vote',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  ...participantVotingFormFields.map((field) {
                    return _buildFormField(
                        context,
                        field,
                        _participantFieldsValuesMap[votingSessionParticipant]![field]!,
                        _participantFieldsFocusNodes[votingSessionParticipant]![field]!,
                        isExcluded);
                  }),
                ],
              ),
      ],
    );
  }

  Widget _buildFooterFormPage(BuildContext context, List<VotingFormField> footerVotingFormFields) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        Text('Final Remarks', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ...footerVotingFormFields.map((field) {
          return _buildFormField(context, field, _footerFieldsValuesMap[field]!,
              _footerFieldsFocusNodes[field]!, false);
        }),
      ],
    );
  }

  Widget _buildFormField(BuildContext context, VotingFormField field,
      TextEditingController controller, FocusNode focusNode, bool isExcluded) {
    final fieldWidget = switch (field.type) {
      VotingFormFieldType.textual => CustomTextFormField(
          controller: controller,
          focusNode: focusNode,
          borderType: InputBorderType.outlined,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          minLines: 1,
          maxLines: 4,
          enabled: !isExcluded,
          validator: isExcluded ? null : (value) => _validateTextualField(value, field.isRequired),
        ),
      VotingFormFieldType.slider => CustomSliderFormField(
          controller: controller,
          votingFormField: field,
          isEnabled: !isExcluded,
          validator:
              (!isExcluded) ? (value) => _validateSliderField(value, field.isRequired) : null,
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${field.question} ${field.isRequired ? '*' : ''}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          fieldWidget,
        ],
      ),
    );
  }
}

String? _validateTextualField(String? value, bool isRequired) {
  if (value == null || value.trim().isEmpty) {
    return (isRequired) ? 'Required' : null;
  }
  return null;
}

String? _validateSliderField(String? value, bool isRequired) {
  if (value == null || value.trim().isEmpty) {
    return (isRequired) ? 'Required' : null;
  }
  return null;
}

/// A helper widget to preserve the state of pages in a PageView.
class _KeepAlivePage extends StatefulWidget {
  final Widget child;

  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is important!
    return widget.child;
  }
}
