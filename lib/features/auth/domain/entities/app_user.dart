import 'package:equatable/equatable.dart';

/// 当前登录用户，隔离掉 Firebase 的 User 类型，方便替换鉴权实现。
class AppUser extends Equatable {
  const AppUser({required this.uid, required this.email});

  final String uid;
  final String email;

  String get initial {
    final String value = email.trim();
    return value.isEmpty ? '?' : value.substring(0, 1).toUpperCase();
  }

  @override
  List<Object?> get props => <Object?>[uid, email];
}
