/// 登录 / 注册表单校验。
abstract final class AuthValidators {
  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? email(String? value) {
    final String text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '请输入邮箱';
    }
    return _email.hasMatch(text) ? null : '邮箱格式不正确';
  }

  static String? password(String? value) {
    final String text = value ?? '';
    if (text.isEmpty) {
      return '请输入密码';
    }
    return text.length < 6 ? '密码至少 6 位' : null;
  }

  /// 确认密码需要跟另一个输入框实时比对，所以传入读取函数。
  static String? Function(String?) confirm(String Function() password) {
    return (String? value) =>
        value == password() ? null : '两次输入的密码不一致';
  }
}
