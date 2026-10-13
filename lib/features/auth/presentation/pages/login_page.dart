import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../validators.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_submit_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email =
      TextEditingController(text: 'demo@crypto.app');
  final TextEditingController _password = TextEditingController(text: '123456');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    context.read<AuthBloc>().add(
          AuthSignInRequested(email: _email.text, password: _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppConfig config = getIt<AppConfig>();

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (AuthState previous, AuthState current) =>
              current.errorMessage != null &&
              current.errorMessage != previous.errorMessage,
          listener: (BuildContext context, AuthState state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const AuthHeader(
                    title: '欢迎回来',
                    subtitle: '登录后查看你的自选行情',
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    controller: _email,
                    label: '邮箱',
                    hintText: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: AuthValidators.email,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _password,
                    label: '密码',
                    hintText: '至少 6 位',
                    obscureText: true,
                    validator: AuthValidators.password,
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.submitting != current.submitting,
                    builder: (BuildContext context, AuthState state) {
                      return AuthSubmitButton(
                        label: '登录',
                        color: AppColors.textPrimary,
                        submitting: state.submitting,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        '还没有账号？',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pushNamed(AppRoutes.registerName),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            '立即注册',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.up,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (config.demoAuth) ...<Widget>[
                    const SizedBox(height: 32),
                    _DemoAuthNotice(firebaseConfigured: config.firebaseReady),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoAuthNotice extends StatelessWidget {
  const _DemoAuthNotice({required this.firebaseConfigured});

  final bool firebaseConfigured;

  @override
  Widget build(BuildContext context) {
    final String message = firebaseConfigured
        ? '当前为本地演示鉴权（AUTH_MODE=demo）。\n'
            '内置账号 demo@crypto.app / 123456。'
        : '未配置 Firebase，当前为本地演示鉴权。\n'
            '内置账号 demo@crypto.app / 123456，也可以直接注册。';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
