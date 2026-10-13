import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../validators.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_submit_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    context.read<AuthBloc>().add(
          AuthSignUpRequested(email: _email.text, password: _password.text),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
        title: const Text(
          '注册账号',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
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
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const AuthHeader(
                    title: '创建你的交易账号',
                    subtitle: '注册成功后将自动登录',
                  ),
                  const SizedBox(height: 28),
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
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _confirm,
                    label: '确认密码',
                    hintText: '请再次输入密码',
                    obscureText: true,
                    validator: AuthValidators.confirm(() => _password.text),
                  ),
                  const SizedBox(height: 28),
                  BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (AuthState previous, AuthState current) =>
                        previous.submitting != current.submitting,
                    builder: (BuildContext context, AuthState state) {
                      return AuthSubmitButton(
                        label: '注册并登录',
                        color: AppColors.up,
                        submitting: state.submitting,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
