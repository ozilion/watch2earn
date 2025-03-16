import 'package:flutter/material.dart';
import 'package:watch2earn/core/theme/app_colors.dart';

import '../../../core/theme/text_styles.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isObscured;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool autofocus;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final void Function(String)? onSubmitted;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.isObscured = false,
    required this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscured,
        keyboardType: keyboardType,
        validator: validator,
        autofocus: autofocus,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onFieldSubmitted: onSubmitted,
        style: AppTextStyles.bodyText.copyWith(
          color: isDark ? Colors.white : AppColors.lightTextColor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          hintText: hintText,
          hintStyle: AppTextStyles.bodyText.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
