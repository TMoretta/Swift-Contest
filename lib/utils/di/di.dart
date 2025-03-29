import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'package:swift_contest/viewmodel/blocs/app_auth_bloc/app_auth_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/app_contest_role_bloc/app_contest_role_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/juror_pages_blocs/juror_contest_details_page_bloc/juror_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/juror_pages_blocs/juror_home_page_bloc/juror_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_creation_page_bloc/organizer_contest_creation_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_contest_details_page_bloc/organizer_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/organizer_pages_blocs/organizer_home_page_bloc/organizer_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_contest_details_page_bloc/participant_contest_details_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_home_page_bloc/participant_home_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/participant_pages_blocs/participant_work_submit_page_bloc/participant_work_submit_page_bloc.dart';
import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_field_bloc/place_picker_field_bloc.dart';
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

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  //* Remotes
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  //* Services
  getIt.registerFactory<JurationService>(
    () => JurationServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<ParticipationService>(
    () => ParticipationServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<ContestService>(
    () => ContestServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<EdgeService>(
    () => EdgeServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<GooglePlaceService>(
    () => GooglePlaceServiceImpl(apiKey: Constants.googlePlacesApiKey),
  );
  getIt.registerFactory<ProfileService>(
    () => ProfileServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<StorageService>(
    () => StorageServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<UserService>(
    () => UserServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<WorkService>(
    () => WorkServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );
  getIt.registerFactory<VotingFormService>(
        () => VotingFormServiceImpl(supabaseClient: getIt<SupabaseClient>()),
  );

  //* Repositories
  getIt.registerFactory<JurationRepository>(
    () => JurationRepositoryImpl(jurationService: getIt<JurationService>()),
  );
  getIt.registerFactory<ParticipationRepository>(
    () => ParticipationRepositoryImpl(participationService: getIt<ParticipationService>()),
  );
  getIt.registerFactory<ContestRepository>(
    () => ContestRepositoryImpl(contestService: getIt<ContestService>()),
  );
  getIt.registerFactory<EdgeRepository>(
    () => EdgeRepositoryImpl(edgeService: getIt<EdgeService>()),
  );
  getIt.registerFactory<GooglePlaceRepository>(
    () => GooglePlaceRepositoryImpl(googlePlaceService: getIt<GooglePlaceService>()),
  );
  getIt.registerFactory<ProfileRepository>(
    () => ProfileRepositoryImpl(profileService: getIt<ProfileService>()),
  );
  getIt.registerFactory<StorageRepository>(
    () => StorageRepositoryImpl(storageService: getIt<StorageService>()),
  );
  getIt.registerFactory<UserRepository>(
    () => UserRepositoryImpl(userService: getIt<UserService>()),
  );
  getIt.registerFactory<WorkRepository>(
    () => WorkRepositoryImpl(workService: getIt<WorkService>()),
  );
  getIt.registerFactory<VotingFormRepository>(
        () => VotingFormRepositoryImpl(votingFormService: getIt<VotingFormService>()),
  );

  //* Singleton Blocs
  getIt.registerSingleton<AppAuthBloc>(
    AppAuthBloc(userRepository: getIt<UserRepository>()),
  );
  getIt.registerLazySingleton<AppContestRoleBloc>(
    () => AppContestRoleBloc(profileRepository: getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<OrganizerHomePageBloc>(
    () => OrganizerHomePageBloc(
      contestRepository: getIt<ContestRepository>(),
      profileRepository: getIt<ProfileRepository>(),
      participationRepository: getIt<ParticipationRepository>(),
      jurationRepository: getIt<JurationRepository>(),
    ),
  );
  getIt.registerLazySingleton<ParticipantHomePageBloc>(
    () => ParticipantHomePageBloc(
      contestRepository: getIt<ContestRepository>(),
      participationRepository: getIt<ParticipationRepository>(),
      jurationRepository: getIt<JurationRepository>(),
      profileRepository: getIt<ProfileRepository>(),
    ),
  );
  getIt.registerLazySingleton<JurorHomePageBloc>(
        () => JurorHomePageBloc(
      contestRepository: getIt<ContestRepository>(),
      participationRepository: getIt<ParticipationRepository>(),
      jurationRepository: getIt<JurationRepository>(),
      profileRepository: getIt<ProfileRepository>(),
    ),
  );
  getIt.registerLazySingleton<OrganizerContestDetailsPageBloc>(
        () => OrganizerContestDetailsPageBloc(
      contestRepository: getIt<ContestRepository>(),
      participationRepository: getIt<ParticipationRepository>(),
      jurationRepository: getIt<JurationRepository>(),
      edgeRepository: getIt<EdgeRepository>(),
      workRepository: getIt<WorkRepository>(),
      profileRepository: getIt<ProfileRepository>(),
      votingFormRepository: getIt<VotingFormRepository>(),
    ),
  );
  getIt.registerLazySingleton<ParticipantContestDetailsPageBloc>(
        () => ParticipantContestDetailsPageBloc(
      workRepository: getIt<WorkRepository>(),
      contestRepository: getIt<ContestRepository>(),
      profileRepository: getIt<ProfileRepository>(),
      participationRepository: getIt<ParticipationRepository>(),
    ),
  );
  getIt.registerLazySingleton<JurorContestDetailsPageBloc>(
        () => JurorContestDetailsPageBloc(
      contestRepository: getIt<ContestRepository>(),
      profileRepository: getIt<ProfileRepository>(),
    ),
  );

  //* Factory Blocs
  getIt.registerFactory<OrganizerContestCreationPageBloc>(
    () => OrganizerContestCreationPageBloc(
      contestRepository: getIt<ContestRepository>(),
      storageRepository: getIt<StorageRepository>(),
    ),
  );
  getIt.registerFactory<PlacePickerFieldBloc>(
    () => PlacePickerFieldBloc(
      googlePlaceRepository: getIt<GooglePlaceRepository>(),
    ),
  );
  getIt.registerFactory<SignInPageBloc>(
    () => SignInPageBloc(userRepository: getIt<UserRepository>()),
  );
  getIt.registerFactory<SignUpPageBloc>(
    () => SignUpPageBloc(userRepository: getIt<UserRepository>()),
  );
  getIt.registerFactory<ParticipantWorkSubmitPageBloc>(
    () => ParticipantWorkSubmitPageBloc(
      workRepository: getIt<WorkRepository>(),
      storageRepository: getIt<StorageRepository>(),
    ),
  );
}
