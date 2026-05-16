import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'base_auth_repository.dart';

class AuthRepository implements BaseAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map((u) => _fromFirebaseUser(u));

  @override
  AppUser? get currentUser => _fromFirebaseUser(_firebaseAuth.currentUser);

  @override
  Future<AppUser?> signUp(
      {required String email, required String password, required String name}) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    
    // Set display name on Firebase Auth
    await userCredential.user?.updateDisplayName(name);
    
    // Save user data to Firestore (Bonus requirement)
    await _firestore.collection('users').doc(userCredential.user?.uid).set({
      'name': name,
      'email': email,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return _fromFirebaseUser(userCredential.user, name: name);
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

  AppUser? _fromFirebaseUser(User? user, {String? name}) {
    if (user == null) return null;
    
    // الأدمين هو أي شخص لديه هذا الإيميل، وسيتم التحقق من كلمة مروره عبر Firebase Auth الفعلي
    final isAdminEmail = user.email == 'admin@admin.com' || 
                         user.email == 'admin@gmail.com' ||
                         user.email == 'admin@coffee.com';
    
    final role = isAdminEmail ? 'admin' : 'user';
    
    return AppUser(
      id: user.uid,
      email: user.email,
      name: name ?? user.displayName,
      role: role,
    );
  }
}
