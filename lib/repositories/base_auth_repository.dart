import '../models/app_user.dart';

abstract class BaseAuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<AppUser?> signUp({required String email, required String password, required String name});

  Future<AppUser?> signIn({required String email, required String password});

  Future<void> signOut();
}
