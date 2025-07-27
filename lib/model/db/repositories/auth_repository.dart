import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swift_contest/model/db/bundles/auth_bundle.dart';
import 'package:swift_contest/model/db/daos/account_dao.dart';
import 'package:swift_contest/model/db/daos/message_dao.dart';
import 'package:swift_contest/model/db/daos/profile_dao.dart';
import 'package:swift_contest/model/db/entities/account.dart';
import 'package:swift_contest/model/db/entities/profile.dart';
import 'package:swift_contest/model/db/types/contest_role.dart';
import 'package:swift_contest/utils/failures/failures.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, bool>> isCurrentUserAuthenticated();

  Future<Either<Failure, AuthBundle>> getCurrentAccountAuthBundle();

  Future<Either<Failure, Account>> updateCurrentAccountEmail({required String email});

  Future<Either<Failure, Unit>> updateCurrentAccountPassword({required String password});

  Future<Either<Failure, Unit>> deleteCurrentAccount();

  Future<Either<Failure, Unit>> markMessageAsRead({required String messageId});

  Future<Either<Failure, Unit>> deleteMessage({required String messageId});

  Future<Either<Failure, Unit>> deleteAllCurrentAccountMessages();

  Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName});

  Future<Either<Failure, Profile>> updateCurrentProfilePrefRole({required ContestRole prefRole});

  Future<Either<Failure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, Unit>> signInWithEmail({required String email});

  Future<Either<Failure, Unit>> signUpWithEmail({required String email, required String fullName});

  Future<Either<Failure, Unit>> signInVerifyOtp({required String email, required String otp});

  Future<Either<Failure, Unit>> signUpVerifyOtp({required String email, required String otp});

  Future<Either<Failure, Unit>> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;
  final AccountDao _accountDao;
  final ProfileDao _profileDao;
  final MessageDao _messageDao;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required AccountDao accountDao,
    required ProfileDao profileDao,
    required MessageDao messageDao,
  })  : _supabase = supabaseClient,
        _accountDao = accountDao,
        _profileDao = profileDao,
        _messageDao = messageDao;

  @override
  Future<Either<Failure, bool>> isCurrentUserAuthenticated() async {
    final eitherAccount = await _accountDao.getNullableCurrent();
    return eitherAccount.fold(
      (failure) => Either.left(failure),
      (success) => Either.right((success != null) ? true : false),
    );
  }

  @override
  Future<Either<Failure, AuthBundle>> getCurrentAccountAuthBundle() async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return left(eitherAccount.getLeft().toNullable()!);
      }
      final account = eitherAccount.getRight().toNullable()!;

      final eitherProfile = await _profileDao.getById(id: account.id);
      if (eitherProfile.isLeft()) {
        return left(eitherProfile.getLeft().toNullable()!);
      }
      final profile = eitherProfile.getRight().toNullable()!;

      final eitherMessages = await _messageDao.getByAccountId(accountId: account.id);
      if (eitherMessages.isLeft()) {
        return left(eitherMessages.getLeft().toNullable()!);
      }
      final messages = eitherMessages.getRight().toNullable()!;

      return Either.right(AuthBundle(account: account, profile: profile, messages: messages));
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Account>> updateCurrentAccountEmail({required String email}) async {
    try {
      final eitherAccount =
          await _accountDao.updateCurrent(userAttributes: UserAttributes(email: email));
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      return right(eitherAccount.getRight().toNullable()!);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCurrentAccountPassword({required String password}) async {
    try {
      final eitherAccount =
          await _accountDao.updateCurrent(userAttributes: UserAttributes(password: password));
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      return right(unit);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCurrentAccount() async {
    try {
      final res = await _supabase.functions.invoke('delete-account');
      if (res.status != 200) {
        return Either.left(Failure(res.data.toString()));
      }
      await _supabase.auth.signOut(scope: SignOutScope.global);
      return Either.right(unit);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessageAsRead({required String messageId}) async {
    try {
      final eitherMessage = await _messageDao.getById(id: messageId);
      if (eitherMessage.isLeft()) {
        return Either.left(eitherMessage.getLeft().toNullable()!);
      }
      final message = eitherMessage.getRight().toNullable()!;

      final eitherUpdate = await _messageDao.update(entity: message.copyWith(isRead: true));
      if (eitherUpdate.isLeft()) {
        return left(eitherUpdate.getLeft().toNullable()!);
      }
      return right(unit);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMessage({required String messageId}) async {
    try {
      final eitherDelete = await _messageDao.deleteById(id: messageId);
      if (eitherDelete.isLeft()) {
        return left(eitherDelete.getLeft().toNullable()!);
      }
      return right(unit);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAllCurrentAccountMessages() async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      final account = eitherAccount.getRight().toNullable()!;
      final eitherDelete = await _messageDao.deleteByAccountId(accountId: account.id);
      if (eitherDelete.isLeft()) {
        return left(eitherDelete.getLeft().toNullable()!);
      }
      return right(unit);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> updateCurrentProfileFullName({required String fullName}) async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      final account = eitherAccount.getRight().toNullable()!;

      final eitherProfile = await _profileDao.getById(id: account.id);
      if (eitherProfile.isLeft()) {
        return Either.left(eitherProfile.getLeft().toNullable()!);
      }
      final oldProfile = eitherProfile.getRight().toNullable()!;

      final eitherUpdate =
          await _profileDao.update(entity: oldProfile.copyWith(fullName: fullName));
      if (eitherUpdate.isLeft()) {
        return left(eitherUpdate.getLeft().toNullable()!);
      }
      final newProfile = eitherUpdate.getRight().toNullable()!;
      return right(newProfile);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Profile>> updateCurrentProfilePrefRole(
      {required ContestRole prefRole}) async {
    try {
      final eitherAccount = await _accountDao.getCurrent();
      if (eitherAccount.isLeft()) {
        return Either.left(eitherAccount.getLeft().toNullable()!);
      }
      final account = eitherAccount.getRight().toNullable()!;

      final eitherProfile = await _profileDao.getById(id: account.id);
      if (eitherProfile.isLeft()) {
        return Either.left(eitherProfile.getLeft().toNullable()!);
      }
      final oldProfile = eitherProfile.getRight().toNullable()!;

      final eitherUpdate =
          await _profileDao.update(entity: oldProfile.copyWith(prefRole: prefRole));
      if (eitherUpdate.isLeft()) {
        return left(eitherUpdate.getLeft().toNullable()!);
      }
      final newProfile = eitherUpdate.getRight().toNullable()!;
      return right(newProfile);
    } on SocketException {
      return Either.left(Failure('Network error'));
    } on Exception {
      return Either.left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);
      final session = response.session;
      if (session == null) {
        return left(Failure('No valid session found'));
      }
      // final account = Account.fromJson(session.user.toJson());
      // if(account.isAdmin) {
      //   await _supabase.auth.signOut();
      //   return left(Failure('Invalid credentials'));
      // }
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      final user = response.user;
      if (user == null) {
        return left(Failure('No valid session found'));
      }
      return Either.right(unit);
      // return right(my.User.fromJson(user.toJson()));
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInWithEmail({required String email}) async {
    try {
      await _supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpWithEmail({
    required String email,
    required String fullName,
  }) async {
    try {
      // final bool res = await _supabase.rpc('verify_user_existence_by_email', params: {'p_email': email});
      // if (res) {
      //   return left(Failure(message: 'An account with this email already exists. Sign in instead'));
      // }
      await _supabase.auth.signInWithOtp(
        shouldCreateUser: true,
        email: email,
        data: {
          'full_name': fullName,
        },
      );
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signInVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );
      final session = response.session;
      if (session == null) {
        return left(Failure('No valid session found'));
      }
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signUpVerifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otp,
      );
      final session = response.session;
      if (session == null) {
        return left(Failure('No valid session found'));
      }
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _supabase.auth.signOut();
      return right(unit);
    } on SocketException {
      return left(Failure('Network error'));
    } on AuthException catch (e) {
      return left(_authExceptionToFailure(e));
    } catch (e) {
      return left(Failure());
    }
  }
}

//* Map the supabase auth exceptions to my custom server exception
Failure _authExceptionToFailure(AuthException exception) {
  if (exception.code != null) {
    switch (exception.code) {
      //* Supabase exceptions
      case 'email_address_invalid':
        return Failure(exception.message);
      case 'email_exists':
        return Failure(exception.message);
      case 'email_not_confirmed':
        return Failure(exception.message);
      case 'invalid_credentials':
        return Failure(exception.message);
      case 'over_request_rate_limit':
        return Failure(exception.message);
      case 'reauthentication_needed':
        return Failure(exception.message);
      case 'request_timeout':
        return Failure(exception.message);
      case 'session_expired':
        return Failure(exception.message);
      case 'session_not_found':
        return Failure(exception.message);
      case 'unexpected_failure':
        return Failure(exception.message);
      case 'user_already_exists':
        return Failure(exception.message);
      case 'user_banned':
        return Failure(exception.message);
      case 'user_not_found':
        return Failure(exception.message);
      case 'validation_failed':
        return Failure(exception.message);
      case 'weak_password':
        return Failure(exception.message);
      case 'otp_disabled':
        return Failure(exception.message);
      case 'over_email_send_rate_limit':
        return Failure(exception.message);
      case 'otp_expired':
        return Failure(exception.message);
      default:
        return Failure();
    }
  } else {
    return Failure();
  }
}
