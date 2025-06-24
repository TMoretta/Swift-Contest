import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:scaled_app/scaled_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/google_place_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/participant_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';

void main() async {
  ScaledWidgetsFlutterBinding.ensureInitialized(
    scaleFactor: (deviceSize) {
      const double widthOfDesign = 375;
      return deviceSize.width / widthOfDesign;
    },
  );
  // WidgetsFlutterBinding.ensureInitialized();

  //* Force vertical orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  //* Load environment variables
  await dotenv.load(fileName: '.env');

  //* Initializing supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(autoRefreshToken: true, detectSessionInUri: true),
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );
  final supabaseClient = Supabase.instance.client;

  //* App
  runApp(
    MultiRepositoryProvider(
      //* Repositories
      providers: [
        RepositoryProvider<GooglePlaceRepository>(
          create: (context) =>
              GooglePlaceRepositoryImpl(apiKey: dotenv.env['GOOGLE_PLACES_API_KEY']!),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<UtilsRepository>(
          create: (context) => UtilsRepositoryImpl(supabaseClient: supabaseClient),
        ),
        // RepositoryProvider<ContestRepository>(
        //   create: (context) => ContestRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<InvitationRepository>(
        //   create: (context) => InvitationRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<JurationRepository>(
        //   create: (context) => JurationRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<ParticipationRepository>(
        //   create: (context) => ParticipationRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<PlaceRepository>(
        //   create: (context) => PlaceRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<ProfileRepository>(
        //   create: (context) => ProfileRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<SimpleJurorRepository>(
        //   create: (context) => SimpleJurorRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<SimpleJurorVoteRepository>(
        //   create: (context) => SimpleJurorVoteRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<SimpleJurorVotingRepository>(
        //   create: (context) => SimpleJurorVotingRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<UserRepository>(
        //   create: (context) => UserRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<JurorVoteRepository>(
        //   create: (context) => JurorVoteRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingFormFieldRepository>(
        //   create: (context) => VotingFormFieldRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingFormRepository>(
        //   create: (context) => VotingFormRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<JurorVotingRepository>(
        //   create: (context) => JurorVotingRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingSessionExclusionRepository>(
        //   create: (context) => VotingSessionExclusionRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingSessionJurationRepository>(
        //   create: (context) => VotingSessionJurationRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingSessionParticipationRepository>(
        //   create: (context) =>
        //       VotingSessionParticipationRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingSessionRepository>(
        //   create: (context) => VotingSessionRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<VotingSessionSimpleJurorRepository>(
        //   create: (context) =>
        //       VotingSessionSimpleJurorRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        // RepositoryProvider<WorkRepository>(
        //   create: (context) => WorkRepositoryImpl(supabaseClient: supabaseClient),
        // ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<OrganizerRepository>(
          create: (context) => OrganizerRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<ParticipantRepository>(
          create: (context) => ParticipantRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<JurorRepository>(
          create: (context) => JurorRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<GenericRepository>(
          create: (context) => GenericRepositoryImpl(supabaseClient: supabaseClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          //* AuthBloc provide authentication management through all the app
          BlocProvider(
            lazy: false,
            create: (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
