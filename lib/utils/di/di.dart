// import 'package:get_it/get_it.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:swift_contest/model/services/contest_service.dart';
// import 'package:swift_contest/model/services/edge_service.dart';
// import 'package:swift_contest/model/services/google_place_service.dart';
// import 'package:swift_contest/model/services/juration_service.dart';
// import 'package:swift_contest/model/services/participation_service.dart';
// import 'package:swift_contest/model/services/profile_service.dart';
// import 'package:swift_contest/model/services/storage_service.dart';
// import 'package:swift_contest/model/services/user_service.dart';
// import 'package:swift_contest/model/services/voting_session_form_service.dart';
// import 'package:swift_contest/model/services/work_service.dart';
// import 'package:swift_contest/utils/constants/constants.dart';
// import 'package:swift_contest/viewmodel/blocs/general_blocs/auth_bloc/auth_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/general_blocs/contest_role_bloc/contest_role_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_in_page_bloc/sign_in_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/pages_blocs/sign_up_page_bloc/sign_up_page_bloc.dart';
// import 'package:swift_contest/viewmodel/blocs/widgets_blocs/place_picker_field_bloc/place_picker_field_bloc.dart';
// import 'package:swift_contest/viewmodel/repositories/contest_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/edge_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/google_place_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/juration_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/participation_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/profile_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/storage_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/user_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/voting_form_repository.dart';
// import 'package:swift_contest/viewmodel/repositories/work_repository.dart';
//
// final GetIt getIt = GetIt.instance;
//
// void setupLocator() {
//   final SupabaseClient supabaseClient = Supabase.instance.client;
//
//   //* Services
//   getIt.registerLazySingleton<JurationService>(
//         () => JurationServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<ParticipationService>(
//         () => ParticipationServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<ContestService>(
//         () => ContestServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<EdgeService>(
//         () => EdgeServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<GooglePlaceService>(
//         () => GooglePlaceServiceImpl(apiKey: Constants.googlePlacesApiKey),
//   );
//   getIt.registerLazySingleton<ProfileService>(
//         () => ProfileServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<StorageService>(
//         () => StorageServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<UserService>(
//         () => UserServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<WorkService>(
//         () => WorkServiceImpl(supabaseClient: supabaseClient),
//   );
//   getIt.registerLazySingleton<VotingFormService>(
//         () => VotingFormServiceImpl(supabaseClient: supabaseClient),
//   );
//
//   //* Repositories
//   getIt.registerLazySingleton<JurationRepository>(
//         () => JurationRepositoryImpl(jurationService: getIt<JurationService>()),
//   );
//   getIt.registerLazySingleton<ParticipationRepository>(
//         () => ParticipationRepositoryImpl(participationService: getIt<ParticipationService>()),
//   );
//   getIt.registerLazySingleton<ContestRepository>(
//         () => ContestRepositoryImpl(contestService: getIt<ContestService>()),
//   );
//   getIt.registerLazySingleton<EdgeRepository>(
//         () => EdgeRepositoryImpl(edgeService: getIt<EdgeService>()),
//   );
//   getIt.registerLazySingleton<GooglePlaceRepository>(
//         () => GooglePlaceRepositoryImpl(googlePlaceService: getIt<GooglePlaceService>()),
//   );
//   getIt.registerLazySingleton<ProfileRepository>(
//         () => ProfileRepositoryImpl(profileService: getIt<ProfileService>()),
//   );
//   getIt.registerLazySingleton<StorageRepository>(
//         () => StorageRepositoryImpl(storageService: getIt<StorageService>()),
//   );
//   getIt.registerLazySingleton<UserRepository>(
//         () => UserRepositoryImpl(userService: getIt<UserService>()),
//   );
//   getIt.registerLazySingleton<WorkRepository>(
//         () => WorkRepositoryImpl(workService: getIt<WorkService>()),
//   );
//   getIt.registerLazySingleton<VotingFormRepository>(
//         () => VotingFormRepositoryImpl(votingFormService: getIt<VotingFormService>()),
//   );
//
//   //* Singleton Blocs
//   // getIt.registerLazySingleton<AuthBloc>(
//   //       () => AuthBloc(userRepository: getIt<UserRepository>()),
//   // );
//   // getIt.registerLazySingleton<ContestRoleBloc>(
//   //       () => ContestRoleBloc(profileRepository: getIt<ProfileRepository>()),
//   // );
//   // getIt.registerLazySingleton<OrganizerHomePageBloc>(
//   //       () => OrganizerHomePageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //     participationRepository: getIt<ParticipationRepository>(),
//   //     jurationRepository: getIt<JurationRepository>(),
//   //   ),
//   // );
//   // getIt.registerLazySingleton<ParticipantHomePageBloc>(
//   //       () => ParticipantHomePageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     participationRepository: getIt<ParticipationRepository>(),
//   //     jurationRepository: getIt<JurationRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //   ),
//   // );
//   // getIt.registerLazySingleton<JurorHomePageBloc>(
//   //       () => JurorHomePageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     participationRepository: getIt<ParticipationRepository>(),
//   //     jurationRepository: getIt<JurationRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //   ),
//   // );
//   // getIt.registerLazySingleton<OrganizerContestDetailsPageBloc>(
//   //       () => OrganizerContestDetailsPageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     participationRepository: getIt<ParticipationRepository>(),
//   //     jurationRepository: getIt<JurationRepository>(),
//   //     edgeRepository: getIt<EdgeRepository>(),
//   //     workRepository: getIt<WorkRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //     votingFormRepository: getIt<VotingFormRepository>(),
//   //   ),
//   // );
//   // getIt.registerLazySingleton<ParticipantContestDetailsPageBloc>(
//   //       () => ParticipantContestDetailsPageBloc(
//   //     workRepository: getIt<WorkRepository>(),
//   //     contestRepository: getIt<ContestRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //     participationRepository: getIt<ParticipationRepository>(),
//   //   ),
//   // );
//   // getIt.registerLazySingleton<JurorContestDetailsPageBloc>(
//   //       () => JurorContestDetailsPageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     profileRepository: getIt<ProfileRepository>(),
//   //   ),
//   // );
//
//   //* Factory Blocs
//   // getIt.registerFactory<OrganizerContestCreationPageBloc>(
//   //   () => OrganizerContestCreationPageBloc(
//   //     contestRepository: getIt<ContestRepository>(),
//   //     storageRepository: getIt<StorageRepository>(),
//   //   ),
//   // );
//   // getIt.registerFactory<PlacePickerFieldBloc>(
//   //   () => PlacePickerFieldBloc(
//   //     googlePlaceRepository: getIt<GooglePlaceRepository>(),
//   //   ),
//   // );
//   // getIt.registerFactory<SignInPageBloc>(
//   //   () => SignInPageBloc(userRepository: getIt<UserRepository>()),
//   // );
//   // getIt.registerFactory<SignUpPageBloc>(
//   //   () => SignUpPageBloc(userRepository: getIt<UserRepository>()),
//   // );
//   // getIt.registerFactory<ParticipantWorkSubmitPageBloc>(
//   //   () => ParticipantWorkSubmitPageBloc(
//   //     workRepository: getIt<WorkRepository>(),
//   //     storageRepository: getIt<StorageRepository>(),
//   //   ),
//   // );
// }
