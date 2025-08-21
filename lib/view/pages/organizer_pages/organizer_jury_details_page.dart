import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';
import 'package:swift_contest/model/database/types/voting_form_field_type.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_app_bar.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_jury_details_page_bloc/organizer_jury_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

@RoutePage()
class OrganizerJuryDetailsPage extends StatefulWidget implements AutoRouteWrapper {
  final String contestId;
  final String juryId;

  const OrganizerJuryDetailsPage({
    @PathParam('contestId') required this.contestId,
    @PathParam('juryId') required this.juryId,
    super.key,
  });

  @override
  State<OrganizerJuryDetailsPage> createState() => _OrganizerJuryDetailsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => OrganizerJuryDetailsPageBloc(
        organizerRepository: context.read(),
      ),
      child: this,
    );
  }
}

class _OrganizerJuryDetailsPageState extends State<OrganizerJuryDetailsPage> {
  late final String contestId;
  late final String juryId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
    juryId = widget.juryId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<OrganizerJuryDetailsPageBloc>().add(OrganizerJuryDetailsPageFetch(juryId: juryId));
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
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
            title: state.juryBundle?.jury.name ?? '',
            actions: [
              if (state.isInitialized) _Menu(juryId: juryId),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
              child: Builder(
                builder: (context) {
                  if (!state.isInitialized) {
                    if (state.status.isFailure) {
                      return Center(
                        child: FilledButton(
                          onPressed: () async {
                            context
                                .read<OrganizerJuryDetailsPageBloc>()
                                .add(OrganizerJuryDetailsPageFetch(juryId: juryId));
                          },
                          child: Text('Retry'),
                        ),
                      );
                    }
                    return VoidWidget();
                  }
                  final juryBundle = state.juryBundle!;
                  final jurationsBundles = juryBundle.jurationsBundles;
                  final invitations = juryBundle.jurorsInvitations;
                  final headerVotingFormFields = juryBundle.votingFormBundle.headerVotingFormFields;
                  final participantVotingFormFields =
                      juryBundle.votingFormBundle.participantVotingFormFields;
                  final footerVotingFormFields = juryBundle.votingFormBundle.footerVotingFormFields;

                  return DefaultTabController(
                    length: (juryBundle.jury.type.isAppointed) ? 3 : 2,
                    child: Column(
                      children: [
                        TabBar(
                          isScrollable: false,
                          tabs: [
                            if (state.juryBundle!.jury.type.isAppointed) Tab(text: 'Joined'),
                            if (state.juryBundle!.jury.type.isAppointed) Tab(text: 'Attended'),
                            if (state.juryBundle!.jury.type.isSimple) Tab(text: 'Token'),
                            Tab(text: 'Form'),
                          ],
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: TabBarView(
                            children: [
                              //* Joined
                              if (state.juryBundle!.jury.type.isAppointed)
                                Scaffold(
                                  body: RefreshIndicator.adaptive(
                                    onRefresh: () async => context
                                        .read<OrganizerJuryDetailsPageBloc>()
                                        .add(OrganizerJuryDetailsPageFetch(juryId: juryId)),
                                    child: (jurationsBundles.isEmpty)
                                        ? ListViewWithCentralLabel(label: 'No juror joined yet')
                                        : ListView.builder(
                                            itemCount: jurationsBundles.length,
                                            itemBuilder: (context, index) {
                                              final jurationBundle = jurationsBundles[index];
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Card(
                                                    elevation: 0.2,
                                                    child: ListTile(
                                                      trailing: IconButton(
                                                        onPressed: () {
                                                          _showRemoveJurorDialog(
                                                              context: context,
                                                              jurationId:
                                                                  jurationBundle.juration.id!,
                                                              juryId: juryId);
                                                        },
                                                        icon: Icon(
                                                          Icons.remove_circle_outline,
                                                          color:
                                                              Theme.of(context).colorScheme.error,
                                                        ),
                                                      ),
                                                      title: Text(
                                                        jurationBundle.juror.fullName,
                                                        style:
                                                            Theme.of(context).textTheme.titleMedium,
                                                      ),
                                                      subtitle: Text(
                                                        jurationBundle.juration.invitationEmail,
                                                        style:
                                                            Theme.of(context).textTheme.bodyMedium,
                                                      ),
                                                    ),
                                                  ),
                                                  if (index == jurationsBundles.length - 1)
                                                    SizedBox(height: 72),
                                                ],
                                              );
                                            },
                                          ),
                                  ),
                                  floatingActionButton: (state.isInitialized)
                                      ? FloatingActionButton.extended(
                                          onPressed: () {
                                            _showInviteDialog(
                                                context: context,
                                                contestId: contestId,
                                                juryId: juryId);
                                          },
                                          icon: Icon(Icons.email),
                                          label: Text('Invite'),
                                        )
                                      : null,
                                ),
                              //* Attended
                              if (state.juryBundle!.jury.type.isAppointed)
                                Scaffold(
                                  body: RefreshIndicator.adaptive(
                                    onRefresh: () async => context
                                        .read<OrganizerJuryDetailsPageBloc>()
                                        .add(OrganizerJuryDetailsPageFetch(juryId: juryId)),
                                    child: (invitations.isEmpty)
                                        ? ListViewWithCentralLabel(label: 'No juror attended')
                                        : ListView.builder(
                                            itemCount: invitations.length,
                                            itemBuilder: (context, index) {
                                              final invitation = invitations[index];
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Card(
                                                    elevation: 0.2,
                                                    child: ListTile(
                                                      title: Text(
                                                        invitation.email,
                                                        style:
                                                            Theme.of(context).textTheme.titleMedium,
                                                      ),
                                                      trailing: IconButton(
                                                        onPressed: () {
                                                          _showDeleteInvitationDialog(
                                                              context: context,
                                                              juryId: juryId,
                                                              jurorInvitationId: invitation.id!);
                                                        },
                                                        icon: Icon(
                                                          Icons.remove,
                                                          color:
                                                              Theme.of(context).colorScheme.error,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (index == invitations.length - 1)
                                                    SizedBox(height: 72),
                                                ],
                                              );
                                            },
                                          ),
                                  ),
                                  floatingActionButton: (state.isInitialized)
                                      ? FloatingActionButton.extended(
                                          onPressed: () => _showInviteDialog(
                                              context: context,
                                              contestId: contestId,
                                              juryId: juryId),
                                          icon: Icon(Icons.email),
                                          label: Text('Invite'),
                                        )
                                      : null,
                                ),
                              //* Token (only for simple juries)
                              if (state.juryBundle!.jury.type.isSimple)
                                Scaffold(
                                  body: RefreshIndicator.adaptive(
                                    onRefresh: () async => context
                                        .read<OrganizerJuryDetailsPageBloc>()
                                        .add(OrganizerJuryDetailsPageFetch(juryId: juryId)),
                                    child: ListView(
                                      children: [
                                        Card(
                                          elevation: 0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer.withAlpha(120),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text.rich(
                                              TextSpan(
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                children: const [
                                                  TextSpan(
                                                    text:
                                                        'This token allows jurors without an account (simple jurors) to join a voting session.\n\n',
                                                  ),
                                                  TextSpan(
                                                    text: '• Share this token ',
                                                    style:
                                                        TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                          'or display the QR code during the event.\n'),
                                                  TextSpan(
                                                    text: '• Regenerate it ',
                                                    style:
                                                        TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  TextSpan(
                                                      text:
                                                          'at any time for security reasons.'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Center(
                                          child: QrImageView(
                                            data: state.juryBundle!.jury.token!,
                                            backgroundColor: Colors.white,
                                            size: 220,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SelectableText(
                                              state.juryBundle!.jury.token!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                letterSpacing: 2,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.copy_outlined),
                                              tooltip: 'Copy to clipboard',
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: state.juryBundle!.jury.token!));
                                                showSnackBar(
                                                    context: context,
                                                    text: 'Token copied to clipboard');
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                          child: FilledButton.icon(
                                            onPressed: () => _showRegenerateTokenDialog(
                                                context: context, juryId: juryId),
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Regenerate Token'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              //* Form
                              Scaffold(
                                body: RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerJuryDetailsPageBloc>()
                                      .add(OrganizerJuryDetailsPageFetch(juryId: juryId)),
                                  child: ListView(
                                    children: [
                                      Card(
                                        elevation: 0,
                                        child: ListTile(
                                          title: Text(
                                            'Name',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: Theme.of(context).colorScheme.secondary),
                                          ),
                                          subtitle:
                                              Text(juryBundle.votingFormBundle.votingForm.name),
                                        ),
                                      ),
                                      Card(
                                        elevation: 0,
                                        child: ListTile(
                                          title: Text(
                                            'Description',
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                color: Theme.of(context).colorScheme.secondary),
                                          ),
                                          subtitle: Text(
                                              juryBundle.votingFormBundle.votingForm.description),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      if (headerVotingFormFields.isNotEmpty)
                                        Text(
                                          'Header form',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary),
                                        ),
                                      ...headerVotingFormFields.map((field) {
                                        return Card(
                                          elevation: 0,
                                          child: ListTile(
                                            leading: switch (field.type) {
                                              VotingFormFieldType.textual =>
                                                Icon(Icons.text_fields),
                                              VotingFormFieldType.slider =>
                                                Icon(Icons.horizontal_distribute),
                                            },
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: switch (field.type) {
                                              VotingFormFieldType.slider => Text(
                                                  '${field.sliderMinValue!} - ${field.sliderMaxValue}'),
                                              _ => null,
                                            },
                                          ),
                                        );
                                      }),
                                      SizedBox(height: 8),
                                      if (participantVotingFormFields.isNotEmpty)
                                        Text(
                                          'Form for each participant',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary),
                                        ),
                                      ...participantVotingFormFields.map((field) {
                                        return Card(
                                          elevation: 0,
                                          child: ListTile(
                                            leading: switch (field.type) {
                                              VotingFormFieldType.textual =>
                                                Icon(Icons.text_fields),
                                              VotingFormFieldType.slider =>
                                                Icon(Icons.horizontal_distribute),
                                            },
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: switch (field.type) {
                                              VotingFormFieldType.slider => Text(
                                                  '${field.sliderMinValue!} - ${field.sliderMaxValue}'),
                                              _ => null,
                                            },
                                          ),
                                        );
                                      }),
                                      SizedBox(height: 8),
                                      if (footerVotingFormFields.isNotEmpty)
                                        Text(
                                          'Footer form',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.secondary),
                                        ),
                                      ...footerVotingFormFields.map((field) {
                                        return Card(
                                          elevation: 0,
                                          child: ListTile(
                                            leading: switch (field.type) {
                                              VotingFormFieldType.textual =>
                                                Icon(Icons.text_fields),
                                              VotingFormFieldType.slider =>
                                                Icon(Icons.horizontal_distribute),
                                            },
                                            title: (field.isRequired)
                                                ? Text('${field.question} *')
                                                : Text(field.question),
                                            subtitle: switch (field.type) {
                                              VotingFormFieldType.slider => Text(
                                                  '${field.sliderMinValue!} - ${field.sliderMaxValue}'),
                                              _ => null,
                                            },
                                          ),
                                        );
                                      }),
                                      SizedBox(height: 72),
                                    ],
                                  ),
                                  // child: (votingFormFields.isEmpty)
                                  //     ? ListViewWithCentralLabel(label: 'No field added')
                                  //     : ListView.builder(
                                  //         itemCount: votingFormFields.length,
                                  //         itemBuilder: (context, index) {
                                  //           final field = votingFormFields[index];
                                  //           return Column(
                                  //             mainAxisSize: MainAxisSize.min,
                                  //             children: [
                                  //               Card(
                                  //                 elevation: 0,
                                  //                 child: ListTile(
                                  //                   leading: Icon(
                                  //                       (field.type.isTextual)
                                  //                           ? Icons.text_fields
                                  //                           : Icons.numbers),
                                  //                   title: (field.isRequired) ? Text('${field.name} *') : Text(field.name),
                                  //                   subtitle: (field.type.isNumeric)
                                  //                       ? Text(
                                  //                           '${prettyDouble(field.minValue!)} - ${prettyDouble(field.maxValue!)}')
                                  //                       : null,
                                  //                 ),
                                  //               ),
                                  //               if (index == votingFormFields.length - 1)
                                  //                 SizedBox(height: 72),
                                  //             ],
                                  //           );
                                  //         },
                                  //       ),
                                ),
                                floatingActionButton: (state.isInitialized)
                                    ? FloatingActionButton.extended(
                                        onPressed: () async {
                                          final bool? res = await context.router.push(
                                              OrganizerVotingFormEditRoute(
                                                  votingFormId: state.juryBundle!.votingFormBundle
                                                      .votingForm.id!));
                                          if (res == true && context.mounted) {
                                            context
                                                .read<OrganizerJuryDetailsPageBloc>()
                                                .add(OrganizerJuryDetailsPageFetch(juryId: juryId));
                                          }
                                        },
                                        backgroundColor:
                                            Theme.of(context).colorScheme.tertiaryContainer,
                                        foregroundColor:
                                            Theme.of(context).colorScheme.onTertiaryContainer,
                                        icon: Icon(Icons.edit),
                                        label: Text('Edit form'),
                                      )
                                    : VoidWidget(),
                              ),
                            ],
                          ),
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
}

void _showInviteDialog({
  required BuildContext context,
  required String contestId,
  required String juryId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();
  final invitationFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocConsumer<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerJuryDetailsPageInviteJuror) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context
                  .read<OrganizerJuryDetailsPageBloc>()
                  .add(OrganizerJuryDetailsPageFetch(juryId: juryId));
              context.router.pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text(
                'Invite a juror',
              ),
              content: Form(
                key: invitationFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextFormField(
                      borderType: InputBorderType.underlined,
                      controller: emailController,
                      focusNode: emailFocusNode,
                      label: 'Email',
                      validator: emailValidator,
                    ),
                  ],
                ),
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
                    if (invitationFormKey.currentState?.validate() ?? false) {
                      context
                          .read<OrganizerJuryDetailsPageBloc>()
                          .add(OrganizerJuryDetailsPageInviteJuror(
                            juryId: juryId,
                            contestId: contestId,
                            email: emailController.text.trim(),
                          ));
                    }
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showRegenerateTokenDialog({
  required BuildContext context,
  required String juryId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocListener<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is OrganizerJuryDetailsPageRegenerateToken) {
              context.router.pop(); // close the dialog
              showSnackBar(context: context, text: 'Token regenerated successfully');
            }
          },
          child: AlertDialog(
            title: const Text('Regenerate Token'),
            content: const Text(
                'Are you sure you want to regenerate the token? The old token will no longer be valid.'),
            actions: [
              TextButton(
                onPressed: () => context.router.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<OrganizerJuryDetailsPageBloc>().add(OrganizerJuryDetailsPageRegenerateToken(juryId: juryId));
                },
                child: const Text('Regenerate'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showRemoveJurorDialog({
  required BuildContext context,
  required String juryId,
  required String jurationId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocConsumer<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerJuryDetailsPageRemoveJuror) {
              context.router.pop();
              showSnackBar(context: context, text: 'Juror removed successfully');
              context
                  .read<OrganizerJuryDetailsPageBloc>()
                  .add(OrganizerJuryDetailsPageFetch(juryId: juryId));
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Remove juror'),
              content: Text('Are you sure you want to remove this juror?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<OrganizerJuryDetailsPageBloc>()
                        .add(OrganizerJuryDetailsPageRemoveJuror(jurationId: jurationId));
                  },
                  child: Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

void _showDeleteInvitationDialog({
  required BuildContext context,
  required String juryId,
  required String jurorInvitationId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocConsumer<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerJuryDetailsPageDeleteJurorInvitation) {
              context.router.pop();
              showSnackBar(context: context, text: 'Invitation deleted successfully');
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text('Delete invitation'),
              content: Text('Are you sure you want to delete this invitation?'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.router.pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    context.read<OrganizerJuryDetailsPageBloc>().add(
                        OrganizerJuryDetailsPageDeleteJurorInvitation(
                            jurorInvitationId: jurorInvitationId));
                  },
                  child: Text('Proceed'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

class _Menu extends StatelessWidget {
  final String juryId;

  const _Menu({required this.juryId});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (option) async {
        switch (option) {
          case 'Edit':
            _showEditJuryDialog(context: context, juryId: juryId);
            break;
          case 'Delete':
            _showDeleteJuryDialog(context: context, juryId: juryId);
            break;
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem(
            value: 'Edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text(
                'Edit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Delete',
            child: ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ];
      },
    );
  }
}

void _showDeleteJuryDialog({
  required BuildContext context,
  required String juryId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocListener<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is OrganizerJuryDetailsPageDeleteJury) {
              context.router.pop();
              showSnackBar(context: context, text: 'Jury deleted successfully');
              context.router.pop(true);
            }
          },
          child: AlertDialog(
            title: const Text('Delete Jury'),
            content: const Text(
                'Are you sure you want to delete this jury? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => context.router.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context
                      .read<OrganizerJuryDetailsPageBloc>()
                      .add(OrganizerJuryDetailsPageDeleteJury(juryId: juryId));
                },
                child: Text('Proceed'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showEditJuryDialog({
  required BuildContext context,
  required String juryId,
}) {
  final organizerJuryDetailsPageBloc = context.read<OrganizerJuryDetailsPageBloc>();
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return BlocProvider.value(
        value: organizerJuryDetailsPageBloc,
        child: BlocListener<OrganizerJuryDetailsPageBloc, OrganizerJuryDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess && state.sourceEvent is OrganizerJuryDetailsPageEditJury) {
              context.router.pop();
              context
                  .read<OrganizerJuryDetailsPageBloc>()
                  .add(OrganizerJuryDetailsPageFetch(juryId: juryId));
              showSnackBar(context: context, text: 'Jury updated successfully');
            }
          },
          child: AlertDialog(
            title: const Text('Edit jury'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    borderType: InputBorderType.underlined,
                    controller: nameController,
                    focusNode: nameFocusNode,
                    label: 'Name',
                    validator: titleValidator,
                  ),
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
                  if (formKey.currentState?.validate() ?? false) {
                    context.read<OrganizerJuryDetailsPageBloc>().add(
                        OrganizerJuryDetailsPageEditJury(
                            juryId: juryId, name: nameController.text.trim()));
                  }
                },
                child: Text('Edit'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
