// import 'dart:io';
//
// import 'package:fpdart/fpdart.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:swift_contest/model/db/bundles/auth_bundle.dart';
// import 'package:swift_contest/model/db/entities/account.dart';
// import 'package:swift_contest/model/db/entities/message.dart';
// import 'package:swift_contest/model/db/entities/profile.dart';
// import 'package:swift_contest/model/db/types/contest_role.dart';
// import 'package:swift_contest/utils/failures/failures.dart';
//
// abstract interface class AuthRepository {
//   Future<Either<Failure,bool>> verifyCurrentUserExistence();
//
//   Future<Either<Failure, AuthBundle>> getCurrentUserAuthBundle();
//
//   Future<Either<Failure, Account>> getCurrentUser();
//
//   Future<Either<Failure, Profile>> getCurrentProfile();
//
//   Future<Either<Failure, List<Message>>> getCurrentProfileMessages();
//
//   Future<Either<Failure, Message>> markMessageAsRead({required String messageId});
//
//   Future<Either<Failure, Unit>> deleteMessage({required String messageId});
//
//   Future<Either<Failure, Unit>> deleteAllCurrentProfileMessages();
//
//   Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName});
//
//   Future<Either<Failure, Profile>> updateCurrentProfilePrefRole({required ContestRole prefRole});
//
//   Future<Either<Failure, Unit>> deleteCurrentAccount();
//
//   Future<Either<Failure, Unit>> signInWithEmail({required String email});
//
//   Future<Either<Failure, Unit>> signUpWithEmail({required String email, required String fullName});
//
//   Future<Either<Failure, Account>> signInVerifyOtp({required String email, required String otp});
//
//   Future<Either<Failure, Account>> signUpVerifyOtp({required String email, required String otp});
//
//   Future<Either<Failure, Account>> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   });
//
//   Future<Either<Failure, Account>> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String fullName,
//   });
//
//   Future<Either<Failure, Unit>> signOut();
// }
//
// class AuthRepositoryImpl implements AuthRepository {
//   final SupabaseClient _supabase;
//
//   AuthRepositoryImpl({required SupabaseClient supabaseClient}) : _supabase = supabaseClient;
//
//   Session? get currentSession => _supabase.auth.currentSession;
//
//   @override
//   Future<Either<Failure,bool>> verifyCurrentUserExistence() async {
//     try {
//       final bool exists = await _supabase.rpc('verify_current_user_existence');
//       return Either.right(exists);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, AuthBundle>> getCurrentUserAuthBundle() async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase
//           .rpc('get_current_user_auth_bundle');
//       return Either.right(AuthBundle.fromJson(res.first));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Account>> getCurrentUser() async {
//     try {
//       final List<Map<String, dynamic>> res =
//           await _supabase.rpc('get_current_user');
//       return Either.right(Account.fromJson(res.first));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Profile>> getCurrentProfile() async {
//     try {
//       final List<Map<String, dynamic>> res =
//           await _supabase.rpc('get_current_profile');
//       return Either.right(Profile.fromJson(res.first));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, List<Message>>> getCurrentProfileMessages() async {
//     try {
//       final List<Map<String, dynamic>> res = await _supabase
//           .rpc('get_current_profile_messages');
//       return Either.right(res.map((e) => Message.fromJson(e)).toList(growable: false));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Message>> markMessageAsRead({required String messageId}) async {
//     try {
//       final Map<String,dynamic> res = await _supabase.rpc('mark_message_as_read', params: {'p_message_id': messageId});
//       return Either.right(Message.fromJson(res));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
//     try {
//       await _supabase.rpc('delete_message', params: {'p_message_id': messageId});
//       return Either.right(unit);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> deleteAllCurrentProfileMessages() async {
//     try {
//       await _supabase.rpc('delete_all_current_profile_messages');
//       return Either.right(unit);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName}) async {
//     try {
//       final Map<String, dynamic> res = await _supabase.rpc('update_current_profile_full_name', params: {
//         'p_full_name': fullName,
//       });
//       return Either.right(Profile.fromJson(res));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Profile>> updateCurrentProfilePrefRole({
//     required ContestRole prefRole,
//   }) async {
//     try {
//       final Map<String, dynamic> res = await _supabase.rpc('update_current_profile_pref_role', params: {
//         'p_pref_role': prefRole.name,
//       });
//       return Either.right(Profile.fromJson(res));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on PostgrestException catch (e) {
//       return Either.left(Failure(e.message));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> deleteCurrentAccount() async {
//     try {
//       await _supabase.rpc('delete_current_account');
//       _supabase.auth.signOut(scope: SignOutScope.global);
//       return Either.right(unit);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.left(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signInWithEmail({required String email}) async {
//     try {
//       await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
//       return Either.right(unit);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.left(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signUpWithEmail({
//     required String email,
//     required String fullName,
//   }) async {
//     try {
//       final bool res =
//           await _supabase.rpc('verify_user_existence_by_email', params: {'p_email': email});
//       if (res) {
//         return Either.left(Failure('An account with this email already exists. Sign in instead'));
//       }
//       await _supabase.auth.signInWithOtp(
//         shouldCreateUser: true,
//         email: email,
//         data: {
//           'full_name': fullName,
//         },
//       );
//       return Either.right(unit);
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.left(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Account>> signInVerifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await _supabase.auth.verifyOTP(
//         type: OtpType.email,
//         email: email,
//         token: otp,
//       );
//       final session = response.session;
//       if (session == null) {
//         return Either.left(Failure('No valid session found'));
//       }
//       return Either.right(Account.fromJson(session.user.toJson()));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.left(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Account>> signUpVerifyOtp({
//     required String email,
//     required String otp,
//   }) async {
//     try {
//       final response = await _supabase.auth.verifyOTP(
//         type: OtpType.signup,
//         email: email,
//         token: otp,
//       );
//       final session = response.session;
//       if (session == null) {
//         return Either.left(Failure('No valid session found'));
//       }
//       return Either.right(Account.fromJson(session.user.toJson()));
//     } on SocketException {
//       return Either.left(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.left(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.left(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Account>> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _supabase.auth.signInWithPassword(email: email, password: password);
//       final session = response.session;
//       if (session == null) {
//         return Either.left(Failure('No valid session found'));
//       }
//       final user = Account.fromJson(session.user.toJson());
//       if(user.isAdmin) {
//         await _supabase.auth.signOut();
//         return Either.left(Failure('Invalid credentials'));
//       }
//       return Either.right(user);
//     } on SocketException {
//       return Either.right(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.right(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.right(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Account>> signUpWithEmailAndPassword({
//     required String fullName,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _supabase.auth.signUp(
//         email: email,
//         password: password,
//         data: {
//           'full_name': fullName,
//         },
//       );
//       final user = response.user;
//       if (user == null) {
//         return Either.right(Failure('No valid session found'));
//       }
//       return Either.right(Account.fromJson(user.toJson()));
//     } on SocketException {
//       return Either.right(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.right(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.right(Failure());
//     }
//   }
//
//   @override
//   Future<Either<Failure, Unit>> signOut() async {
//     try {
//       await _supabase.auth.signOut();
//       return Either.right(unit);
//     } on SocketException {
//       return Either.right(Failure('Network error'));
//     } on AuthException catch (e) {
//       return Either.right(_authExceptionToRepositoryFailure(e));
//     } catch (e) {
//       return Either.right(Failure());
//     }
//   }
// }
//
// //* Map the supabase auth exceptions to my custom server exception
// Failure _authExceptionToRepositoryFailure(AuthException exception) {
//   if (exception.code != null) {
//     switch (exception.code) {
//       //* Supabase exceptions
//       case 'email_address_invalid':
//         return Failure(exception.message);
//       case 'email_exists':
//         return Failure(exception.message);
//       case 'email_not_confirmed':
//         return Failure(exception.message);
//       case 'invalid_credentials':
//         return Failure(exception.message);
//       case 'over_request_rate_limit':
//         return Failure(exception.message);
//       case 'reauthentication_needed':
//         return Failure(exception.message);
//       case 'request_timeout':
//         return Failure(exception.message);
//       case 'session_expired':
//         return Failure(exception.message);
//       case 'session_not_found':
//         return Failure(exception.message);
//       case 'unexpected_failure':
//         return Failure(exception.message);
//       case 'user_already_exists':
//         return Failure(exception.message);
//       case 'user_banned':
//         return Failure(exception.message);
//       case 'user_not_found':
//         return Failure(exception.message);
//       case 'validation_failed':
//         return Failure(exception.message);
//       case 'weak_password':
//         return Failure(exception.message);
//       case 'otp_disabled':
//         return Failure(exception.message);
//       case 'over_email_send_rate_limit':
//         return Failure(exception.message);
//       case 'otp_expired':
//         return Failure(exception.message);
//       default:
//         return Failure();
//     }
//   } else {
//     return Failure();
//   }
// }
