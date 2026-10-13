import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// App 启动时订阅登录状态。
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => <Object?>[email, password];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// 内部事件：鉴权状态流推来的结果。
final class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final AppUser? user;

  @override
  List<Object?> get props => <Object?>[user];
}
