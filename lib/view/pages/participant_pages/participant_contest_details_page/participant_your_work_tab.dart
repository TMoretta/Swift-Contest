import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/utils/functions/show_snack_bar.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/enums/bloc_status.dart';

class ParticipantYourWorkTab extends StatefulWidget {
  final String contestId;

  const ParticipantYourWorkTab({required this.contestId, super.key});

  @override
  State<ParticipantYourWorkTab> createState() => _ParticipantYourWorkTabState();
}

class _ParticipantYourWorkTabState extends State<ParticipantYourWorkTab> {
  late User user;
  late String contestId;

  @override
  void initState() {
    super.initState();
    contestId = widget.contestId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<ParticipantContestDetailsPageBloc>().state;
    user = context.read<AuthBloc>().state.authBundle!.user;
    if (state.status.isInitial) {
      context
          .read<ParticipantContestDetailsPageBloc>()
          .add(ParticipantContestDetailsPageInit(contestId: contestId, participantId: user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
      listener: (context, state) {
        if (state.message != null) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case BlocStatus.initial:
          case BlocStatus.loading:
          case BlocStatus.failure:
            if (state.sourceEvent is ParticipantContestDetailsPageInit) {
              return RefreshIndicator.adaptive(
                onRefresh: () async {
                  context.read<ParticipantContestDetailsPageBloc>().add(
                      ParticipantContestDetailsPageInit(
                          contestId: contestId, participantId: user.id));
                },
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                ),
              );
            } else {
              continue successCase;
            }
          successCase:
          case BlocStatus.success:
            return Scaffold(
              body: RefreshIndicator.adaptive(
                onRefresh: () async => context
                    .read<ParticipantContestDetailsPageBloc>()
                    .add(ParticipantContestDetailsPageInit(
                      contestId: contestId,
                      participantId: user.id,
                    )),
                child: (state.submittedWork == null)
                    ? ListView(
                        children: [
                          Center(
                            child: Text('No work submitted yet'),
                          )
                        ],
                      )
                    : ListView(
                        children: [
                          //*Title
                          Text(
                            state.submittedWork!.name,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          //* Images carousel
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.submittedWork!.imagesUrls.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    state.submittedWork!.imagesUrls[index],
                                    fit: BoxFit.contain,
                                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                      if (wasSynchronouslyLoaded || frame != null) {
                                        return child;
                                      }
                                      return const Loader();
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          //* Description
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              Text(state.submittedWork!.description,
                                  style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      ),
              ),
              floatingActionButton: BlocBuilder<ParticipantContestDetailsPageBloc,
                  ParticipantContestDetailsPageState>(
                builder: (context, state) {
                  if (state.submittedWork == null) {
                    return FilledButton(
                      onPressed: () async {
                        final bool? res = await context.pushNamed(AppRouter.participantWorkSubmit,
                            extra: contestId);
                        if (res == true) {
                          if (context.mounted) {
                            context.read<ParticipantContestDetailsPageBloc>().add(
                                ParticipantContestDetailsPageInit(
                                    contestId: contestId, participantId: user.id));
                          }
                        }
                      },
                      child: Text('Submit your work'),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            );
        }
      },
    );
  }
}
