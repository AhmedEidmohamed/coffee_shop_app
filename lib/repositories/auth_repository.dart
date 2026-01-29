import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'base_auth_repository.dart';

class AuthRepository implements BaseAuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((u) => _fromFirebaseUser(u));

  @override
  Future<AppUser?> signUp(
      {required String email, required String password}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _fromFirebaseUser(userCredential.user);
  }

  @override
  Future<AppUser?> signIn(
      {required String email, required String password}) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _fromFirebaseUser(userCredential.user);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  AppUser? _fromFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(id: user.uid, email: user.email);
  }
}
