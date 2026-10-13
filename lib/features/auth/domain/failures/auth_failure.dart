/// 鉴权错误，message 可以直接展示给用户。
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure($message)';
}
