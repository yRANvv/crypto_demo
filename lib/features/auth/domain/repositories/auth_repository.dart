import '../entities/app_user.dart';

abstract class AuthRepository {
  /// 登录状态流，登录和登出都会推送新值。
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({required String email, required String password});

  Future<void> signOut();
}
