import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:swift_contest/model/data_models/user.dart';
import 'package:swift_contest/model/services/user_service.dart';
import 'package:swift_contest/utils/exceptions/unsafe_exception.dart';
import 'package:swift_contest/utils/failures/failure.dart';

//* Interface
abstract interface class UserRepository {
  Stream<AuthChange> get authChanges;

  Either<Failure, User> getCurrentUser();

  Future<Either<Failure, User>> getUserById({required String id});

  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, Unit>> signOut();
}

//* Implementation
class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl({required UserService userService}) : _userService = userService;

  @override
  Stream<AuthChange> get authChanges => _userService.authChanges;

  @override
  Either<Failure, User> getCurrentUser() {
    try {
      final result = _userService.getCurrentUser();
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getUserById({required String id}) async {
    try {
      final result = await _userService.getUserById(id: id);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result =
          await _userService.signInWithEmailAndPassword(email: email, password: password);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      final result = await _userService.signOut();
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final result = await _userService.signUpWithEmailAndPassword(
          email: email, password: password, fullName: fullName);
      return right(result);
    } on UnsafeException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
