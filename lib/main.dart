import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/repositories/auth_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/contest_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/invitation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_vote_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/juror_voting_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/participation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/place_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/profile_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/simple_juror_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/simple_juror_vote_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/simple_juror_voting_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/user_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_field_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_form_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_exclusion_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_juration_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_participation_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/voting_session_simple_juror_repository.dart';
import 'package:swift_contest/model/repositories/crud_repositories/work_repository.dart';
import 'package:swift_contest/model/repositories/edge_repository.dart';
import 'package:swift_contest/model/repositories/google_place_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/juror_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/organizer_repository.dart';
import 'package:swift_contest/model/repositories/role_repositories/participant_repository.dart';
import 'package:swift_contest/model/repositories/storage_repository.dart';
import 'package:swift_contest/model/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/blocs/auth_bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClientOptions(autoRefreshToken: true, detectSessionInUri: true),
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );

  final supabaseClient = Supabase.instance.client;

  runApp(
    MultiRepositoryProvider(
      //* Repositories
      providers: [
        RepositoryProvider<ContestRepository>(
          create: (context) => ContestRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<EdgeRepository>(
          create: (context) => EdgeRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<GooglePlaceRepository>(
          create: (context) => GooglePlaceRepositoryImpl(apiKey: dotenv.env['GOOGLE_PLACES_API_KEY']!),
        ),
        RepositoryProvider<InvitationRepository>(
          create: (context) => InvitationRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<JurationRepository>(
          create: (context) => JurationRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<ParticipationRepository>(
          create: (context) => ParticipationRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<PlaceRepository>(
          create: (context) => PlaceRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<SimpleJurorRepository>(
          create: (context) => SimpleJurorRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<SimpleJurorVoteRepository>(
          create: (context) => SimpleJurorVoteRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<SimpleJurorVotingRepository>(
          create: (context) => SimpleJurorVotingRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<UtilsRepository>(
            create: (context) => UtilsRepositoryImpl(supabaseClient: supabaseClient)),
        RepositoryProvider<JurorVoteRepository>(
          create: (context) => JurorVoteRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingFormFieldRepository>(
          create: (context) => VotingFormFieldRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingFormRepository>(
          create: (context) => VotingFormRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<JurorVotingRepository>(
          create: (context) => JurorVotingRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingSessionExclusionRepository>(
          create: (context) => VotingSessionExclusionRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingSessionJurationRepository>(
          create: (context) => VotingSessionJurationRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingSessionParticipationRepository>(
          create: (context) =>
              VotingSessionParticipationRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingSessionRepository>(
          create: (context) => VotingSessionRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<VotingSessionSimpleJurorRepository>(
          create: (context) =>
              VotingSessionSimpleJurorRepositoryImpl(supabaseClient: supabaseClient),
        ),
        RepositoryProvider<WorkRepository>(
          create: (context) => WorkRepositoryImpl(supabaseClient: supabaseClient),
        ),
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
      ],
      child: MultiBlocProvider(
        providers: [
          //* AuthBloc provide authentication management through all the app
          BlocProvider(
            lazy: false,
            create: (context) => AuthBloc(
              profileRepository: context.read<ProfileRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
