import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/model/database/types/jury_type.dart';
import 'package:swift_contest/utils/labels/labels.dart';
import 'package:swift_contest/utils/router/app_router.gr.dart';
import 'package:swift_contest/utils/validators/validators.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/list_view_with_central_label.dart';
import 'package:swift_contest/view/widgets/overlay_loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/view/widgets/void_widget.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/types/bloc_status.dart';

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
                if(!state.isInitialized) {
                  if(state.status.isFailure) {
                    return Center(child: FilledButton(onPressed: ()async => context
                        .read<OrganizerContestDetailsPageBloc>()
                        .add(OrganizerContestDetailsPageFetch(contestId: contestId)), child: Text('Retry'),),);
                  }
                  return VoidWidget();
                }
                final juriesBundles = state.contestDetailsBundle!.juriesBundles;
                return RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<OrganizerContestDetailsPageBloc>()
                      .add(OrganizerContestDetailsPageFetch(contestId: contestId)),
                  child: (juriesBundles.isEmpty)
                      ? ListViewWithCentralLabel(label: 'No jury added yet')
                      : ListView.builder(
                    itemCount: juriesBundles.length,
                    itemBuilder: (context, index) {
                      final juryBundle = juriesBundles[index];
                      return Card(
                        elevation: 0.1,
                        child: ListTile(
                          onTap: () async {
                            final bool? res = await context.router.push(
                                OrganizerJuryDetailsRoute(
                                    contestId: contestId, juryId: juryBundle.jury.id!));
                            if (res == true && context.mounted) {
                              context.read<OrganizerContestDetailsPageBloc>().add(
                                  OrganizerContestDetailsPageFetch(contestId: contestId));
                            }
                          },
                          trailing: (juryBundle.jury.type.isAppointed) ? Icon(Icons.star) : Icon(Icons.star_border),
                          title: Text(juryBundle.jury.name),
                          subtitle: (juryBundle.jury.type.isAppointed) ? Text(
                              'Joined: ${juryBundle.jurationsBundles.length}, Attended: ${juryBundle.jurorsInvitations.length}') : null,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _showCreateJuryDialog(context: context, contestId: contestId);
            },
            icon: Icon(Icons.create),
            label: Text('Create jury'),
          ),
        );
      },
    );
  }
}

void _showCreateJuryDialog({required BuildContext context, required String contestId}) {
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  final juryFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  JuryType chosenJuryType = JuryType.appointed;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return BlocProvider.value(
          value: organizerContestDetailsPageBloc,
          child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
            listener: (context, state) {
              if (state.status.isSuccess &&
                  state.sourceEvent is OrganizerContestDetailsPageCreateJury) {
                showSnackBar(context: context, text: 'Jury created successfully');
                context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageFetch(contestId: contestId));
                context.router.pop();
              }
            },
            builder: (context, state) {
              return AlertDialog(
                title: Text(
                  'New jury',
                ),
                content: Form(
                  key: juryFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        borderType: InputBorderType.outlined,
                        controller: nameController,
                        focusNode: nameFocusNode,
                        label: 'Name',
                        validator: noEmptyValidator,
                      ),
                      Text('Jury type'),
                      SizedBox(height: 2),
                      RadioMenuButton<JuryType>(
                        value: JuryType.appointed,
                        groupValue: chosenJuryType,
                        onChanged: (value) => setState(() => chosenJuryType = value!),
                        child: Text(
                          'Appointed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      RadioMenuButton<JuryType>(
                        value: JuryType.simple,
                        groupValue: chosenJuryType,
                        onChanged: (value) => setState(() => chosenJuryType = value!),
                        child: Text(
                          'Simple',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
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
                      if (juryFormKey.currentState?.validate() ?? false) {
                        context.read<OrganizerContestDetailsPageBloc>().add(
                            OrganizerContestDetailsPageCreateJury(
                                contestId: contestId,
                                juryName: nameController.text.trim(),
                                juryType: chosenJuryType));
                      }
                    },
                    child: const Text('Proceed'),
                  ),
                ],
              );
            },
          ),
        );
      });
    },
  );
}
