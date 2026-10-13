import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  final AuthRepository _repository;

  StreamSubscription<AppUser?>? _subscription;

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) {
    _subscription ??= _repository
        .authStateChanges()
        .listen((AppUser? user) => add(AuthUserChanged(user)));
  }

  /// 登录状态只由这一处驱动，登录 / 注册 / 登出都走 authStateChanges。
  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final AppUser? user = event.user;
    emit(
      state.copyWith(
        status:
            user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated,
        user: user,
        clearUser: user == null,
        submitting: false,
        clearError: true,
      ),
    );
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) {
    return _submit(
      emit,
      () => _repository.signIn(email: event.email, password: event.password),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) {
    return _submit(
      emit,
      () => _repository.signUp(email: event.email, password: event.password),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
    await _repository.signOut();
  }

  Future<void> _submit(
    Emitter<AuthState> emit,
    Future<AppUser> Function() action,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      await action();
      emit(state.copyWith(submitting: false, clearError: true));
    } on AuthFailure catch (failure) {
      emit(state.copyWith(submitting: false, errorMessage: failure.message));
    } catch (error) {
      emit(state.copyWith(submitting: false, errorMessage: '操作失败：$error'));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
