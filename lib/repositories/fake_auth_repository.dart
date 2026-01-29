import 'dart:async';
import '../models/app_user.dart';
import 'base_auth_repository.dart';

class FakeAuthRepository implements BaseAuthRepository {
  AppUser? _user;
  final _controller = StreamController<AppUser?>.broadcast();

  FakeAuthRepository() {
    // start unauthenticated
    _controller.add(null);
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AppUser?> signUp(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    _user = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(), email: email);
    _controller.add(_user);
    return _user;
  }

  @override
  Future<AppUser?> signIn(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));
    // For fake, accept any credentials
    _user = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(), email: email);
    _controller.add(_user);
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}
