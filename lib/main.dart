import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/utils/constants/constants.dart';
import 'package:swift_contest/utils/di/di.dart';
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/app_contest_role_bloc/app_contest_role_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/juror_pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Constants.supabaseUrl,
    anonKey: Constants.supabaseAnonKey,
    authOptions: FlutterAuthClientOptions(autoRefreshToken: true, detectSessionInUri: true),
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );
  setupDependencyInjection();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AppAuthBloc>()),
        BlocProvider(create: (context) => getIt<AppContestRoleBloc>()),
        BlocProvider(create: (context) => getIt<OrganizerHomePageBloc>()),
        BlocProvider(create: (context) => getIt<ParticipantHomePageBloc>()),
        BlocProvider(create: (context) => getIt<JurorHomePageBloc>()),
        BlocProvider(create: (context) => getIt<OrganizerContestDetailsPageBloc>()),
      ],
      child: App(),
    ),
  );
}
