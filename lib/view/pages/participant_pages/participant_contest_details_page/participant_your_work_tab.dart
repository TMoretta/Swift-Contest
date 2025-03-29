import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:swift_contest/utils/router/go_router.dart';
import 'package:swift_contest/view/widgets/loader.dart';
import 'package:swift_contest/view/widgets/show_snack_bar.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/utils/bloc_status.dart';

class ParticipantYourWorkTab extends StatefulWidget {
  final String contestId;
  final String userId;

  const ParticipantYourWorkTab({super.key, required this.contestId, required this.userId});

  @override
  State<ParticipantYourWorkTab> createState() => _ParticipantYourWorkTabState();
}

class _ParticipantYourWorkTabState extends State<ParticipantYourWorkTab> {

  @override
  void initState() {
    super.initState();
    final state = context.read<ParticipantContestDetailsPageBloc>().state;
    if(state.ownParticipation == null) {
      context
          .read<ParticipantContestDetailsPageBloc>()
          .add(ParticipantContestDetailsPageGetOwnWork(contestId: widget.contestId,participantId: widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParticipantContestDetailsPageBloc,ParticipantContestDetailsPageState>(
      listener: (context, state) {
        if (state.status == BlocStatus.failure) {
          showSnackBar(context: context, text: state.message!);
        }
      },
      builder: (context, state) {
        if(state.status == BlocStatus.loading) {
          return Loader();
        }
        if(state.status == BlocStatus.success) {
          return Stack(
            fit: StackFit.loose,
            children: [
              RefreshIndicator.adaptive(
                  onRefresh: () async => context
                      .read<ParticipantContestDetailsPageBloc>()
                      .add(ParticipantContestDetailsPageGetOwnWork(
                    contestId: widget.contestId,
                    participantId: widget.userId,
                  )),
                  child: (state.ownWork == null)
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
                        state.ownWork!.name,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      //* Images carousel
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.ownWork!.imagesUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.network(
                                state.ownWork!.imagesUrls[index],
                                fit: BoxFit.contain,
                                frameBuilder:
                                    (context, child, frame, wasSynchronouslyLoaded) {
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
                          Text(state.ownWork!.description, style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  )),
              //* FAB
              BlocBuilder<ParticipantContestDetailsPageBloc, ParticipantContestDetailsPageState>(
                builder: (context, state) {
                  if (state.ownWork == null) {
                    return Positioned(
                      bottom: 16,
                      right: 0,
                      child: FilledButton(
                        onPressed: () {
                          context.pushNamed(AppRouter.participantWorkSubmit, extra: widget.contestId);
                        },
                        child: Text('Submit your work'),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          );
        }
        return RefreshIndicator.adaptive(
          onRefresh: () async{
            context
                .read<ParticipantContestDetailsPageBloc>()
                .add(ParticipantContestDetailsPageGetOwnWork(contestId: widget.contestId,participantId: widget.userId));
          },
          child: ListView(),
        );
      },
    );
  }
}
