import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';
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
import 'package:swift_contest/model/database/repositories/auth_repository.dart';
import 'package:swift_contest/model/database/repositories/juror_repository.dart';
import 'package:swift_contest/model/database/repositories/organizer_repository.dart';
import 'package:swift_contest/model/database/repositories/participant_repository.dart';
import 'package:swift_contest/model/database/repositories/storage_repository.dart';
import 'package:swift_contest/model/google_place/repositories/google_place_repository.dart';
import 'package:swift_contest/model/local/repositories/theme_repository.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/deep_link_bloc/deep_link_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/theme_bloc/theme_bloc.dart';

void main() async {
  // ScaledWidgetsFlutterBinding.ensureInitialized(
  //   scaleFactor: (deviceSize) {
  //     const double widthOfDesign = 350;
  //     return deviceSize.width / widthOfDesign;
  //   },
  // );
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

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

  if (!kIsWeb) {
    await HydratedBloc.storage.clear();
  }

  final SupabaseClient supabase = Supabase.instance.client;
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
          create: (context) => GooglePlaceRepositoryImpl(supabase: supabase),
          // GooglePlaceRepositoryImpl(apiKey: dotenv.env['GOOGLE_PLACES_API_KEY']!),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(supabaseClient: supabase),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(supabaseClient: supabase),
        ),
        RepositoryProvider<OrganizerRepository>(
          create: (context) => OrganizerRepositoryImpl(
            supabaseClient: supabase
          ),
        ),
        RepositoryProvider<ParticipantRepository>(
          create: (context) => ParticipantRepositoryImpl(supabaseClient: supabase),
        ),
        RepositoryProvider<JurorRepository>(
          create: (context) => JurorRepositoryImpl(supabaseClient: supabase),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          //* AuthBloc provide authentication management through all the app
          BlocProvider<AuthBloc>(
            lazy: false,
            create: (context) => AuthBloc(authRepository: context.read()),
          ),
          BlocProvider<ThemeBloc>(
            lazy: false,
            create: (context) => ThemeBloc(themeRepository: context.read()),
          ),
          BlocProvider<DeepLinkBloc>(
            lazy: false,
            create: (context) => DeepLinkBloc(
              participantRepository: context.read(),
              jurorRepository: context.read(),
            ),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
