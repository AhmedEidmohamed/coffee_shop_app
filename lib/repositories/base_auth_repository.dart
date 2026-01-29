import '../models/app_user.dart';

abstract class BaseAuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> signUp({required String email, required String password});

  Future<AppUser?> signIn({required String email, required String password});

  Future<void> signOut();
}
