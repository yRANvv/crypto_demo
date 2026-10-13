import 'dart:async';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import 'auth_remote_data_source.dart';

/// 本地演示鉴权，只在没有 Firebase 配置时启用。
///
/// 流程和真实实现一致，只是账号存在内存里（刷新页面即丢失），
/// 内置账号 demo@crypto.app / 123456。
class DemoAuthRemoteDataSource implements AuthRemoteDataSource {
  DemoAuthRemoteDataSource() {
    _accounts['demo@crypto.app'] = '123456';
  }

  final Map<String, String> _accounts = <String, String>{};
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    await _delay();
    final String normalized = _normalize(email);
    final String? stored = _accounts[normalized];
    if (stored == null) {
      throw const AuthFailure('账号不存在，请先注册');
    }
    if (stored != password) {
      throw const AuthFailure('邮箱或密码不正确');
    }
    return _emit(normalized);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    await _delay();
    final String normalized = _normalize(email);
    if (_accounts.containsKey(normalized)) {
      throw const AuthFailure('该邮箱已被注册');
    }
    _accounts[normalized] = password;
    return _emit(normalized);
  }

  @override
  Future<void> signOut() async {
    await _delay();
    _current = null;
    _controller.add(null);
  }

  AppUser _emit(String email) {
    final AppUser user = AppUser(uid: _uidFor(email), email: email);
    _current = user;
    _controller.add(user);
    return user;
  }

  String _uidFor(String email) {
    int hash = 0;
    for (final int unit in email.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return 'demo-${hash.toRadixString(16).padLeft(8, '0')}';
  }

  String _normalize(String email) => email.trim().toLowerCase();

  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 400));
}
