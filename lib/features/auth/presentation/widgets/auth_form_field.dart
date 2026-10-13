import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthFormField extends StatelessWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.chip,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(color: AppColors.up, width: 1.2),
            errorBorder: _border(color: AppColors.down, width: 1.2),
            focusedErrorBorder: _border(color: AppColors.down, width: 1.2),
            errorStyle: const TextStyle(fontSize: 12, color: AppColors.down),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border({Color? color, double width = 0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: width),
    );
  }
}
