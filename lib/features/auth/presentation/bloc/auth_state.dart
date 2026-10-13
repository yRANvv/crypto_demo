import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

enum AuthStatus {
  /// 还没拿到第一次登录状态。
  unknown,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.submitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final AppUser? user;

  /// 登录 / 注册请求进行中。
  final bool submitting;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool clearUser = false,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, user, submitting, errorMessage];
}
