import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerJuriesTab extends StatefulWidget {
  final String contestId;

  const OrganizerJuriesTab({required this.contestId, super.key});

  @override
  State<OrganizerJuriesTab> createState() => _OrganizerJuriesTabState();
}

class _OrganizerJuriesTabState extends State<OrganizerJuriesTab> {
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void dispose() {
    context.hideLoader();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Builder(
              builder: (context) {
                switch(state.status) {
                  case BlocStatus.initial:
                    return VoidWidget();
                  case BlocStatus.loading:
                    if (!state.isInitialized) {
                      return VoidWidget();
                    } else {
                      continue successCase;
                    }
                  case BlocStatus.failure:
                    if (!state.isInitialized) {
                      return RefreshIndicator.adaptive(
                        onRefresh: () async => context
                            .read<OrganizerContestDetailsPageBloc>()
                            .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                        child: ListViewWithCentralLabel(label: Labels.anErrorOccurred),
                      );
                    } else {
                      continue successCase;
                    }
                  successCase:
                  case BlocStatus.success:
                    return VoidWidget();
                }
              },
            ),
          ),
          floatingActionButton: FilledButton(
            onPressed: () {
              _showAddJuryDialog(context: context, contestId: contestId);
            },
            child: Text('Invite'),
          ),
        );
      },
    );
  }
}

void _showAddJuryDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  final invitationFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final emailFocusNode = FocusNode();

  showDialog(
    context: context,
    builder: (context) {
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageSendJurorInvite) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context
                  .read<OrganizerContestDetailsPageBloc>()
                  .add(OrganizerContestDetailsPageFetch(contestId: contestId));
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
                          .read<OrganizerContestDetailsPageBloc>()
                          .add(OrganizerContestDetailsPageSendJurorInvite(
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
