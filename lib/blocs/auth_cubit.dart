import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/app_user.dart';
import '../repositories/base_auth_repository.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final AppUser? user;
  final String? error;

  const AuthState({this.isLoading = false, this.user, this.error});

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
  factory AuthState.authenticated(AppUser user) => AuthState(user: user);
  factory AuthState.unauthenticated() => const AuthState();
  factory AuthState.failure(String error) => AuthState(error: error);

  @override
  List<Object?> get props => [isLoading, user, error];
}

class AuthCubit extends Cubit<AuthState> {
  final BaseAuthRepository _authRepository;
  late final StreamSubscription<AppUser?> _authSub;

  AuthCubit({required BaseAuthRepository authRepository})
      : _authRepository = authRepository,
        super(authRepository.currentUser != null 
            ? AuthState.authenticated(authRepository.currentUser!) 
            : AuthState.initial()) {
    _authSub = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.unauthenticated());
      }
    });
  }

  Future<void> signUp({required String email, required String password, required String name}) async {
    emit(AuthState.loading());
    try {
      final user =
          await _authRepository.signUp(email: email, password: password, name: name);
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.failure('Unknown error'));
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(AuthState.loading());
    try {
      final user =
          await _authRepository.signIn(email: email, password: password);
      if (user != null) {
        emit(AuthState.authenticated(user));
      } else {
        emit(AuthState.failure('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthState.failure(e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  @override
  Future<void> close() {
    _authSub.cancel();
    return super.close();
  }
}
