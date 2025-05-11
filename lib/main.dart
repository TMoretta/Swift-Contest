import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/app.dart';
import 'package:swift_contest/model/services/contest_service.dart';
import 'package:swift_contest/model/services/edge_service.dart';
import 'package:swift_contest/model/services/google_place_service.dart';
import 'package:swift_contest/model/services/invitation_service.dart';
import 'package:swift_contest/model/services/juration_service.dart';
import 'package:swift_contest/model/services/participation_service.dart';
import 'package:swift_contest/model/services/place_service.dart';
import 'package:swift_contest/model/services/profile_service.dart';
import 'package:swift_contest/model/services/simple_juror_voting_service.dart';
import 'package:swift_contest/model/services/storage_service.dart';
import 'package:swift_contest/model/services/user_service.dart';
import 'package:swift_contest/model/services/utils_service.dart';
import 'package:swift_contest/model/services/vote_service.dart';
import 'package:swift_contest/model/services/voting_form_field_service.dart';
import 'package:swift_contest/model/services/voting_form_service.dart';
import 'package:swift_contest/model/services/voting_service.dart';
import 'package:swift_contest/model/services/voting_session_juror_service.dart';
import 'package:swift_contest/model/services/voting_session_participant_service.dart';
import 'package:swift_contest/model/services/voting_session_procedure_service.dart';
import 'package:swift_contest/model/services/voting_session_service.dart';
import 'package:swift_contest/model/services/voting_session_simple_juror_service.dart';
import 'package:swift_contest/model/services/voting_session_token_service.dart';
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
import 'package:swift_contest/viewmodel/repositories/invitation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
import 'package:swift_contest/viewmodel/repositories/place_repository.dart';
import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
import 'package:swift_contest/viewmodel/repositories/simple_juror_voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
import 'package:swift_contest/viewmodel/repositories/user_repository.dart';
import 'package:swift_contest/viewmodel/repositories/utils_repository.dart';
import 'package:swift_contest/viewmodel/repositories/vote_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_field_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_participant_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_procedure_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_simple_juror_repository.dart';
import 'package:swift_contest/viewmodel/repositories/voting_session_token_repository.dart';
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
  final InvitationService invitationService = InvitationServiceImpl(supabaseClient: supabaseClient);
  final JurationService jurationService = JurationServiceImpl(supabaseClient: supabaseClient);
  final ParticipationService participationService =
      ParticipationServiceImpl(supabaseClient: supabaseClient);
  final PlaceService placeService = PlaceServiceImpl(supabaseClient: supabaseClient);
  final ProfileService profileService = ProfileServiceImpl(supabaseClient: supabaseClient);
  final SimpleJurorVotingService simpleJurorVotingService = SimpleJurorVotingServiceImpl(supabaseClient: supabaseClient);
  final StorageService storageService = StorageServiceImpl(supabaseClient: supabaseClient);
  final UserService userService = UserServiceImpl(supabaseClient: supabaseClient);
  final UtilsService utilsService = UtilsServiceImpl(supabaseClient: supabaseClient);
  final VoteService voteService = VoteServiceImpl(supabaseClient: supabaseClient);
  final VotingFormFieldService votingFormFieldService =
      VotingFormFieldServiceImpl(supabaseClient: supabaseClient);
  final VotingFormService votingFormService = VotingFormServiceImpl(supabaseClient: supabaseClient);
  final VotingService votingService = VotingServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionJurorService votingSessionJurorService =
      VotingSessionJurorServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionParticipantService votingSessionParticipantService =
      VotingSessionParticipantServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionProcedureService votingSessionProcedureService =
      VotingSessionProcedureServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionService votingSessionService =
      VotingSessionServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionSimpleJurorService votingSessionSimpleJurorService = VotingSessionSimpleJurorServiceImpl(supabaseClient: supabaseClient);
  final VotingSessionTokenService votingSessionTokenService = VotingSessionTokenServiceImpl(supabaseClient: supabaseClient);
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
        RepositoryProvider<InvitationRepository>(
          create: (context) => InvitationRepositoryImpl(invitationService: invitationService),
        ),
        RepositoryProvider<JurationRepository>(
          create: (context) => JurationRepositoryImpl(jurationService: jurationService),
        ),
        RepositoryProvider<ParticipationRepository>(
          create: (context) =>
              ParticipationRepositoryImpl(participationService: participationService),
        ),
        RepositoryProvider<PlaceRepository>(
          create: (context) => PlaceRepositoryImpl(placeService: placeService),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(profileService: profileService),
        ),
        RepositoryProvider<SimpleJurorVotingRepository>(
          create: (context) => SimpleJurorVotingRepositoryImpl(simpleJurorVotingService: simpleJurorVotingService),
        ),
        RepositoryProvider<StorageRepository>(
          create: (context) => StorageRepositoryImpl(storageService: storageService),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(userService: userService),
        ),
        RepositoryProvider<UtilsRepository>(
            create: (context) => UtilsRepositoryImpl(utilsService: utilsService)),
        RepositoryProvider<VoteRepository>(
          create: (context) => VoteRepositoryImpl(voteService: voteService),
        ),
        RepositoryProvider<VotingFormFieldRepository>(
          create: (context) =>
              VotingFormFieldRepositoryImpl(votingFormFieldService: votingFormFieldService),
        ),
        RepositoryProvider<VotingFormRepository>(
          create: (context) => VotingFormRepositoryImpl(votingFormService: votingFormService),
        ),
        RepositoryProvider<VotingRepository>(
          create: (context) => VotingRepositoryImpl(votingService: votingService),
        ),
        RepositoryProvider<VotingSessionJurorRepository>(
          create: (context) => VotingSessionJurorRepositoryImpl(
              votingSessionJurorService: votingSessionJurorService),
        ),
        RepositoryProvider<VotingSessionParticipantRepository>(
          create: (context) => VotingSessionParticipantRepositoryImpl(
              votingSessionParticipantService: votingSessionParticipantService),
        ),
        RepositoryProvider<VotingSessionProcedureRepository>(
          create: (context) => VotingSessionProcedureRepositoryImpl(
              votingSessionProcedureService: votingSessionProcedureService),
        ),
        RepositoryProvider<VotingSessionRepository>(
          create: (context) =>
              VotingSessionRepositoryImpl(votingSessionService: votingSessionService),
        ),
        RepositoryProvider<VotingSessionSimpleJurorRepository>(
          create: (context) => VotingSessionSimpleJurorRepositoryImpl(votingSessionSimpleJurorService: votingSessionSimpleJurorService),
        ),
        RepositoryProvider<VotingSessionTokenRepository>(
          create: (context) => VotingSessionTokenRepositoryImpl(votingSessionTokenService: votingSessionTokenService),
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
              placeRepository: context.read<PlaceRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => ParticipantJoinedContestsBloc(
              contestRepository: context.read<ContestRepository>(),
              profileRepository: context.read<ProfileRepository>(),
              participationRepository: context.read<ParticipationRepository>(),
              jurationRepository: context.read<JurationRepository>(),
              placeRepository: context.read<PlaceRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => JurorJoinedContestsBloc(
              contestRepository: context.read<ContestRepository>(),
              profileRepository: context.read<ProfileRepository>(),
              participationRepository: context.read<ParticipationRepository>(),
              jurationRepository: context.read<JurationRepository>(),
              placeRepository: context.read<PlaceRepository>(),
            ),
          ),
        ],
        child: App(),
      ),
    ),
  );
}
