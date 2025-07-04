import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/model/repositories/generic_repository.dart';
import 'package:swift_contest/model/repositories/google_place_repository.dart';
import 'package:swift_contest/model/repositories/juror_repository.dart';
import 'package:swift_contest/model/repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/participant_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';

void main() async {
  // ScaledWidgetsFlutterBinding.ensureInitialized(
  //   scaleFactor: (deviceSize) {
  //     const double widthOfDesign = 350;
  //     return deviceSize.width / widthOfDesign;
  //   },
  // );
  WidgetsFlutterBinding.ensureInitialized();

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

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

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
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<GenericRepository>(
          create: (context) => GenericRepositoryImpl(supabaseClient: supabaseClient),
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
