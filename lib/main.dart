import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/database/daos/account_dao.dart';
import 'package:swift_contest/model/database/daos/contest_dao.dart';
import 'package:swift_contest/model/database/daos/juration_dao.dart';
import 'package:swift_contest/model/database/daos/juror_invitation_dao.dart';
import 'package:swift_contest/model/database/daos/jury_dao.dart';
import 'package:swift_contest/model/database/daos/message_dao.dart';
import 'package:swift_contest/model/database/daos/participant_invitation_dao.dart';
import 'package:swift_contest/model/database/daos/participation_dao.dart';
import 'package:swift_contest/model/database/daos/place_dao.dart';
import 'package:swift_contest/model/database/daos/profile_dao.dart';
import 'package:swift_contest/model/database/daos/voting_form_dao.dart';
import 'package:swift_contest/model/database/daos/voting_form_field_dao.dart';
import 'package:swift_contest/model/database/daos/voting_form_submission_dao.dart';
import 'package:swift_contest/model/database/daos/voting_form_submission_value_dao.dart';
import 'package:swift_contest/model/database/daos/voting_session_dao.dart';
import 'package:swift_contest/model/database/daos/voting_session_exclusion_dao.dart';
import 'package:swift_contest/model/database/daos/voting_session_juration_dao.dart';
import 'package:swift_contest/model/database/daos/voting_session_participation_dao.dart';
import 'package:swift_contest/model/database/daos/work_dao.dart';
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/google_place/repositories/google_place_repository.dart';
import 'package:swift_contest/model/local/repositories/theme_repository.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/theme_bloc/theme_bloc.dart';

void main() async {
  // ScaledWidgetsFlutterBinding.ensureInitialized(
  //   scaleFactor: (deviceSize) {
  //     const double widthOfDesign = 350;
  //     return deviceSize.width / widthOfDesign;
  //   },
  // );
  WidgetsFlutterBinding.ensureInitialized();

  // configureUrlStrategy();

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

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  if(!kIsWeb) {
    await HydratedBloc.storage.clear();
  }


  final SupabaseClient supabase = Supabase.instance.client;
  final AccountDao accountDao = AccountDaoImpl(supabase: supabase);
  final ContestDao contestDao = ContestDaoImpl(supabase: supabase);
  final JurationDao jurationDao = JurationDaoImpl(supabase: supabase);
  final JurorInvitationDao jurorInvitationDao = JurorInvitationDaoImpl(supabase: supabase);
  final VotingFormSubmissionDao votingFormSubmissionDao = VotingFormSubmissionDaoImpl(supabase: supabase);
  final VotingFormSubmissionValueDao votingFormSubmissionValueDao = VotingFormSubmissionValueDaoImpl(supabase: supabase);
  final JuryDao juryDao = JuryDaoImpl(supabase: supabase);
  final MessageDao messageDao = MessageDaoImpl(supabase: supabase);
  final ParticipantInvitationDao participantInvitationDao =
      ParticipantInvitationDaoImpl(supabase: supabase);
  final ParticipationDao participationDao = ParticipationDaoImpl(supabase: supabase);
  final PlaceDao placeDao = PlaceDaoImpl(supabase: supabase);
  final ProfileDao profileDao = ProfileDaoImpl(supabase: supabase);
  final VotingFormDao votingFormDao = VotingFormDaoImpl(supabase: supabase);
  final VotingFormFieldDao votingFormFieldDao = VotingFormFieldDaoImpl(supabase: supabase);
  final VotingSessionDao votingSessionDao = VotingSessionDaoImpl(supabase: supabase);
  final VotingSessionExclusionDao votingSessionExclusionDao =
      VotingSessionExclusionDaoImpl(supabase: supabase);
  final VotingSessionJurationDao votingSessionJurationDao =
      VotingSessionJurationDaoImpl(supabase: supabase);
  final VotingSessionParticipationDao votingSessionParticipationDao =
      VotingSessionParticipationDaoImpl(supabase: supabase);
  final WorkDao workDao = WorkDaoImpl(supabase: supabase);
  final sharedPreferencesInstance = await SharedPreferences.getInstance();

  //* App
  runApp(
    MultiRepositoryProvider(
      //* Repositories
      providers: [
        RepositoryProvider<ThemeRepository>(
          create: (context) => ThemeRepositoryImpl(
            sharedPreferencesInstance: sharedPreferencesInstance,
            key: 'app_theme',
          ),
        ),
        RepositoryProvider<GooglePlaceRepository>(
          create: (context) =>
              GooglePlaceRepositoryImpl(apiKey: dotenv.env['GOOGLE_PLACES_API_KEY']!),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(supabaseClient: supabase),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
              supabaseClient: supabase,
              profileDao: profileDao,
              messageDao: messageDao,
              accountDao: accountDao),
        ),
        RepositoryProvider<OrganizerRepository>(
          create: (context) => OrganizerRepositoryImpl(
            supabaseClient: supabase,
            profileDao: profileDao,
            placeDao: placeDao,
            participationDao: participationDao,
            jurationDao: jurationDao,
            contestDao: contestDao,
            jurorInvitationDao: jurorInvitationDao,
            juryDao: juryDao,
            participantInvitationDao: participantInvitationDao,
            votingSessionDao: votingSessionDao,
            accountDao: accountDao,
            votingFormDao: votingFormDao,
            votingFormFieldDao: votingFormFieldDao,
          ),
        ),
        RepositoryProvider<ParticipantRepository>(
          create: (context) => ParticipantRepositoryImpl(
            supabaseClient: supabase,
            participationDao: participationDao,
            accountDao: accountDao,
          ),
        ),
        RepositoryProvider<JurorRepository>(
          create: (context) => JurorRepositoryImpl(
            supabaseClient: supabase,
            accountDao: accountDao,
            jurationDao: jurationDao,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          //* AuthBloc provide authentication management through all the app
          BlocProvider<AuthBloc>(
            lazy: false,
            create: (context) => AuthBloc(authRepository: context.read<AuthRepository>()),
          ),
          BlocProvider<ThemeBloc>(
            lazy: false,
            create: (context) => ThemeBloc(themeRepository: context.read<ThemeRepository>()),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
