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
  AppUser? get currentUser => _user;

  @override
  Future<AppUser?> signUp(
      {required String email, required String password, required String name}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(), email: email, name: name);
    _controller.add(_user);
    return _user;
  }

  @override
  Future<AppUser?> signIn(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // تأمين حساب الإدمن بكلمة مرور محددة
    if ((email == 'admin@admin.com' || email == 'admin@gmail.com') && password != 'admin123') {
      throw Exception('كلمة المرور الخاصة بالمدير غير صحيحة. استخدم admin123');
    }

    // For fake, accept any other credentials
    final role = (email == 'admin@admin.com' || email == 'admin@gmail.com') ? 'admin' : 'user';
    _user = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(), email: email, role: role);
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
