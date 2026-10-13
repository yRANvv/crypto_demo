import '../../domain/entities/app_user.dart';

/// 鉴权数据源：Firebase 与本地演示实现共用这套接口。
abstract class AuthRemoteDataSource {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> signUp({required String email, required String password});

  Future<void> signOut();
}
