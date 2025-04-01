import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/services/contest_service.dart';
import 'package:swift_contest/model/services/edge_service.dart';
import 'package:swift_contest/model/services/google_place_service.dart';
import 'package:swift_contest/model/services/juration_service.dart';
import 'package:swift_contest/model/services/participation_service.dart';
import 'package:swift_contest/model/services/profile_service.dart';
import 'package:swift_contest/model/services/storage_service.dart';
import 'package:swift_contest/model/services/user_service.dart';
import 'package:swift_contest/model/services/voting_form_service.dart';
import 'package:swift_contest/model/services/work_service.dart';
import 'package:swift_contest/utils/constants/constants.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/auth_bloc/auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/contest_role_bloc/contest_role_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/juror_joined_contests_bloc/juror_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/organizer_created_contests_bloc/organizer_created_contests_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/global_blocs/participant_joined_contests_bloc/participant_joined_contests_bloc.dart';
import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
import 'package:swift_contest/viewmodel/repositories/edge_repository.dart';
import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/work_repository.dart';

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

  final supabaseClient = Supabase.instance.client;

  //* Services
  final ContestService contestService = ContestServiceImpl(supabaseClient: supabaseClient);
  final EdgeService edgeService = EdgeServiceImpl(supabaseClient: supabaseClient);
  final GooglePlaceService googlePlaceService =
      GooglePlaceServiceImpl(apiKey: Constants.googlePlacesApiKey);
  final JurationService jurationService = JurationServiceImpl(supabaseClient: supabaseClient);
  final ParticipationService participationService =
      ParticipationServiceImpl(supabaseClient: supabaseClient);
  final ProfileService profileService = ProfileServiceImpl(supabaseClient: supabaseClient);
  final StorageService storageService = StorageServiceImpl(supabaseClient: supabaseClient);
  final UserService userService = UserServiceImpl(supabaseClient: supabaseClient);
  final VotingFormService votingFormService = VotingFormServiceImpl(supabaseClient: supabaseClient);
  final WorkService workService = WorkServiceImpl(supabaseClient: supabaseClient);

  runApp(
    MultiRepositoryProvider(
      //* Repositories
      providers: [
        RepositoryProvider<ContestRepository>(
          create: (context) => ContestRepositoryImpl(contestService: contestService),
        ),
        RepositoryProvider<EdgeRepository>(
          create: (context) => EdgeRepositoryImpl(edgeService: edgeService),
        ),
        RepositoryProvider<GooglePlaceRepository>(
          create: (context) => GooglePlaceRepositoryImpl(googlePlaceService: googlePlaceService),
        ),
        RepositoryProvider<JurationRepository>(
          create: (context) => JurationRepositoryImpl(jurationService: jurationService),
        ),
        RepositoryProvider<ParticipationRepository>(
          create: (context) =>
              ParticipationRepositoryImpl(participationService: participationService),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(profileService: profileService),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(storageService: storageService),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(userService: userService),
        ),
        RepositoryProvider<VotingFormRepository>(
          create: (context) => VotingFormRepositoryImpl(votingFormService: votingFormService),
        ),
        RepositoryProvider<WorkRepository>(
          create: (context) => WorkRepositoryImpl(workService: workService),
        ),
      ],
      child: MultiBlocProvider(
        //* Global Blocs
        providers: [
          // BlocProvider(
          //   create: (context) => DataTransferBloc()
          // ),
          BlocProvider(
            lazy: false,
            create: (context) => AuthBloc(
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ContestRoleBloc(
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => OrganizerCreatedContestsBloc(
              contestRepository: context.read<ContestRepository>(),
              profileRepository: context.read<ProfileRepository>(),
              participationRepository: context.read<ParticipationRepository>(),
              jurationRepository: context.read<JurationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ParticipantJoinedContestsBloc(
              contestRepository: context.read<ContestRepository>(),
              profileRepository: context.read<ProfileRepository>(),
              participationRepository: context.read<ParticipationRepository>(),
              jurationRepository: context.read<JurationRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => JurorJoinedContestsBloc(
              contestRepository: context.read<ContestRepository>(),
              profileRepository: context.read<ProfileRepository>(),
              participationRepository: context.read<ParticipationRepository>(),
              jurationRepository: context.read<JurationRepository>(),
            ),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
