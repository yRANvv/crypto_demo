import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import 'auth_remote_data_source.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final AppUser? user = _map(credential.user);
      if (user == null) {
        throw const AuthFailure('登录失败，请稍后重试');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_describe(error));
    }
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final AppUser? user = _map(credential.user);
      if (user == null) {
        throw const AuthFailure('注册失败，请稍后重试');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_describe(error));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AppUser? _map(User? user) {
    if (user == null) {
      return null;
    }
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  /// 把 Firebase 的错误码转成能直接给用户看的文案。
  String _describe(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return '邮箱格式不正确';
      case 'user-not-found':
        return '账号不存在，请先注册';
      case 'wrong-password':
      case 'invalid-credential':
        return '邮箱或密码不正确';
      case 'email-already-in-use':
        return '该邮箱已被注册';
      case 'weak-password':
        return '密码强度不足，至少 6 位';
      case 'user-disabled':
        return '该账号已被禁用';
      case 'too-many-requests':
        return '操作过于频繁，请稍后再试';
      case 'network-request-failed':
        return '网络异常，请检查网络连接';
      case 'operation-not-allowed':
        return '未在 Firebase 控制台开启邮箱密码登录';
      default:
        return error.message ?? '操作失败，请稍后重试';
    }
  }
}
