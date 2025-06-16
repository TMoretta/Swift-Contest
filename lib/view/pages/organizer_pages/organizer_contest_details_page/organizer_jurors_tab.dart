import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/bundles/juration_bundle.dart';
import 'package:swift_contest/model/data_models/invitation.dart';
import 'package:swift_contest/model/enums/juror_status.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/themes/color_scheme_x.dart';
import 'package:swift_contest/view/widgets/custom_text_form_field.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class OrganizerJurorsTab extends StatefulWidget {
  final String contestId;

  const OrganizerJurorsTab({required this.contestId, super.key});

  @override
  State<OrganizerJurorsTab> createState() => _OrganizerJurorsTabState();
}

class _OrganizerJurorsTabState extends State<OrganizerJurorsTab> {
  late final String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<OrganizerContestDetailsPageBloc>().state;
    if (state.status.isInitial) {
      context
          .read<OrganizerContestDetailsPageBloc>()
          .add(OrganizerContestDetailsPageInit(contestId: contestId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
      builder: (context, state) {
        switch (state.status) {
          case BlocStatus.initial:
            return SizedBox.shrink();
          case BlocStatus.loading:
            return Loader();
          case BlocStatus.failure:
            if (state.sourceEvent is OrganizerContestDetailsPageInit) {
              return RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<OrganizerContestDetailsPageBloc>()
                    .add(OrganizerContestDetailsPageInit(contestId: contestId)),
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                ),
              );
            } else {
              continue successCase;
            }
          successCase:
          case BlocStatus.success:
            final List<JurationBundle> joinedJurationsBundles =
                state.contestDetailsBundle!.joinedJurationsBundles;
            final List<Invitation> jurorsInvitations =
                state.contestDetailsBundle!.jurorsInvitations;
            final List<JurationBundle> leftJurationsBundles =
                state.contestDetailsBundle!.leftJurationsBundles;

            return Scaffold(
              body: DefaultTabController(
                length: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jurors',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Card(
                        elevation: 0,
                        child: SizedBox(
                          height: 30,
                          child: TabBar(
                            labelColor: Theme.of(context).colorScheme.white,
                            unselectedLabelColor: Theme.of(context).colorScheme.grey7,
                            isScrollable: true,
                            dividerColor: Colors.transparent,
                            tabAlignment: TabAlignment.center,
                            splashBorderRadius: BorderRadius.circular(16),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            tabs: [
                              Tab(text: 'Joined'),
                              Tab(text: 'Attended'),
                              Tab(text: 'Left'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          //* Joined
                          (joinedJurationsBundles.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Text('No juror joined yet'),
                                    ],
                                  ),
                                )
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: joinedJurationsBundles.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(color: Colors.grey),
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(joinedJurationsBundles[index].juror.fullName),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          //* Attended
                          (jurorsInvitations.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Text('No juror attended. Invite one'),
                                    ],
                                  ),
                                )
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView.builder(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount: jurorsInvitations.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(color: Colors.grey),
                                            bottom: BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(jurorsInvitations[index].email),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                          //* Left
                          (leftJurationsBundles.isEmpty)
                              ? RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    children: [
                                      Text('No juror left'),
                                    ],
                                  ),
                                )
                              : RefreshIndicator.adaptive(
                                  onRefresh: () async => context
                                      .read<OrganizerContestDetailsPageBloc>()
                                      .add(OrganizerContestDetailsPageRefresh(contestId: contestId)),
                                  child: ListView.builder(
                                    itemCount: leftJurationsBundles.length,
                                    itemBuilder: (context, index) {
                                      if (leftJurationsBundles[index].juration.jurorStatus ==
                                          JurorStatus.left) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              // top: BorderSide(color: Colors.grey),
                                              bottom: BorderSide(color: Colors.grey),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text(leftJurationsBundles[index].juror.fullName),
                                          ),
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                    SizedBox(height: 52),
                  ],
                ),
              ),
              floatingActionButton: FilledButton(
                onPressed: () async {
                  final bool? res = await _showInviteDialog(context: context, contestId: contestId);
                  if (res == true) {
                    if (context.mounted) {
                      context
                          .read<OrganizerContestDetailsPageBloc>()
                          .add(OrganizerContestDetailsPageRefresh(contestId: contestId));
                    }
                  }
                },
                child: Text('Invite'),
              ),
            );

        }
      },
    );
  }
}

Future<bool?> _showInviteDialog({required BuildContext context, required String contestId}) async{
  final organizerContestDetailsPageBloc = context.read<OrganizerContestDetailsPageBloc>();
  return await showDialog(
    context: context,
    builder: (context) {
      final invitationFormKey = GlobalKey<FormState>();
      final emailController = TextEditingController();
      return BlocProvider.value(
        value: organizerContestDetailsPageBloc,
        child: BlocConsumer<OrganizerContestDetailsPageBloc, OrganizerContestDetailsPageState>(
          listener: (context, state) {
            if (state.status.isSuccess &&
                state.sourceEvent is OrganizerContestDetailsPageSendJurorInvite) {
              showSnackBar(context: context, text: 'Email sent successfully');
              context.pop(true);
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case BlocStatus.initial:
                return SizedBox.shrink();
              case BlocStatus.loading:
                return Loader();
              case BlocStatus.failure:
              case BlocStatus.success:
                return AlertDialog(
                  title: Text(
                    'Invite a juror',
                  ),
                  content: Form(
                    key: invitationFormKey,
                    child: CustomTextFormFieldUnderlined(
                      controller: emailController,
                      label: 'Email',
                      validator: _emailValidator,
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: (!state.status.isLoading)
                              ? () {
                                  context.pop();
                                }
                              : null,
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: (!state.status.isLoading)
                              ? () {
                                  if (invitationFormKey.currentState?.validate() ?? false) {
                                    context
                                        .read<OrganizerContestDetailsPageBloc>()
                                        .add(OrganizerContestDetailsPageSendJurorInvite(
                                          contestId: contestId,
                                          email: emailController.text.trim(),
                                        ));
                                    // context.pop();
                                  }
                                }
                              : null,
                          child: const Text('Ok'),
                        ),
                      ],
                    )
                  ],
                );
            }
          },
        ),
      );
    },
  );
}

//* Email validator
String? _emailValidator(String? value) {
  String? valueTrm = value?.trim();
  if (valueTrm == null || valueTrm.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(valueTrm)) {
    return 'Please enter a valid email';
  }
  return null;
}
