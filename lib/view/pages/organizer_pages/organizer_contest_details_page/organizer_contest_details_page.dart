import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_jurors_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';

class OrganizerContestDetailsPage extends StatefulWidget {
  final String contestId;

  const OrganizerContestDetailsPage({required this.contestId, super.key});

  @override
  State<OrganizerContestDetailsPage> createState() => _OrganizerContestDetailsPageState();
}

class _OrganizerContestDetailsPageState extends State<OrganizerContestDetailsPage> {

  @override
  void initState() {
    super.initState();
    final contestDetailsState = context.read<OrganizerContestDetailsPageBloc>().state;
    if(contestDetailsState.contest?.id != widget.contestId) {
      context.read<OrganizerContestDetailsPageBloc>().add(OrganizerContestDetailsPageClean());
    }
  }

  @override
  Widget build(BuildContext context) {
    final contestId = widget.contestId;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(
            'Your contest',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
        shadowColor: Theme.of(context).colorScheme.black,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        elevation: 0.8,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: DefaultTabController(
                length: 5,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                        alignment: Alignment.center,
                        child: Card(
                          elevation: 0.5,
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
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            tabs: [
                              Tab(text: 'Details'),
                              Tab(text: 'Participants'),
                              Tab(text: 'Jurors'),
                              Tab(text: 'Works'),
                              Tab(text: 'Voting'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            OrganizerDetailsTab(
                              contestId: contestId,
                            ),
                            OrganizerParticipantsTab(
                              contestId: contestId,
                            ),
                            OrganizerJurorsTab(
                              contestId: contestId,
                            ),
                            OrganizerWorksTab(
                              contestId: contestId,
                            ),
                            OrganizerVotingTab(
                              contestId: contestId,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:swift_contest/utils/di/di.dart';
// import 'package:swift_contest/utils/themes/color_scheme_extension.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_details_tab.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_jurors_tab.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_participants_tab.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_voting_tab.dart';
// import 'package:swift_contest/view/pages/organizer_pages/organizer_contest_details_page/organizer_works_tab.dart';
// import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
//
// class OrganizerContestDetailsPage extends StatefulWidget {
//   final String contestId;
//
//   const OrganizerContestDetailsPage({required this.contestId, super.key});
//
//   @override
//   State<OrganizerContestDetailsPage> createState() => _OrganizerContestDetailsPageState();
// }
//
// class _OrganizerContestDetailsPageState extends State<OrganizerContestDetailsPage> {
//   @override
//   Widget build(BuildContext context) {
//     final contestId = widget.contestId;
//     return BlocProvider<OrganizerContestDetailsPageBloc>(
//       create: (context) => getIt<OrganizerContestDetailsPageBloc>(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: FittedBox(
//             child: Text(
//               'Your contest',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w800,
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//             ),
//           ),
//           actions: [
//             IconButton(
//               onPressed: () {},
//               icon: Icon(Icons.more_vert),
//               color: Theme.of(context).colorScheme.secondary,
//             ),
//           ],
//           shadowColor: Theme.of(context).colorScheme.black,
//           surfaceTintColor: Theme.of(context).colorScheme.surface,
//           elevation: 0.8,
//         ),
//         body: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SizedBox(
//                 width: constraints.maxWidth,
//                 height: constraints.maxHeight,
//                 child: DefaultTabController(
//                   length: 5,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Align(
//                           alignment: Alignment.center,
//                           child: Card(
//                             elevation: 0.5,
//                             child: TabBar(
//                               labelColor: Theme.of(context).colorScheme.white,
//                               unselectedLabelColor: Theme.of(context).colorScheme.grey7,
//                               isScrollable: true,
//                               dividerColor: Colors.transparent,
//                               tabAlignment: TabAlignment.center,
//                               splashBorderRadius: BorderRadius.circular(16),
//                               indicatorSize: TabBarIndicatorSize.tab,
//                               indicator: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(16),
//                                 color: Theme.of(context).colorScheme.primary,
//                               ),
//                               tabs: [
//                                 Tab(text: 'Details'),
//                                 Tab(text: 'Participants'),
//                                 Tab(text: 'Jurors'),
//                                 Tab(text: 'Works'),
//                                 Tab(text: 'Voting'),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(horizontal: 20),
//                           child: TabBarView(
//                             physics: NeverScrollableScrollPhysics(),
//                             children: [
//                               OrganizerDetailsTab(
//                                 contestId: contestId,
//                               ),
//                               OrganizerParticipantsTab(
//                                 contestId: contestId,
//                               ),
//                               OrganizerJurorsTab(
//                                 contestId: contestId,
//                               ),
//                               OrganizerWorksTab(
//                                 contestId: contestId,
//                               ),
//                               OrganizerVotingTab(
//                                 contestId: contestId,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
