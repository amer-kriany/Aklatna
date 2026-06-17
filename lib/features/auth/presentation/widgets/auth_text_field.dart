import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/auth/presentation/widgets/auth_styles.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.label,
    required this.hint,
    required this.iconAsset,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final String iconAsset;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: AuthStyles.label, textAlign: TextAlign.right),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AuthStyles.fieldHeight),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPassword && _obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            textAlign: TextAlign.right,
            style: AuthStyles.input,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AuthStyles.hint,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.only(
                right: 41,
                left: widget.isPassword ? 44 : 13,
                top: 13,
                bottom: 13,
              ),
              enabledBorder: _border(AppColors.cardBorder),
              focusedBorder: _border(AppColors.primaryDark),
              border: _border(AppColors.cardBorder),
              prefixIcon: widget.isPassword
                  ? _VisibilityButton(
                      isObscured: _obscureText,
                      onPressed: () {
                        setState(() => _obscureText = !_obscureText);
                      },
                    )
                  : null,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  widget.iconAsset,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    AppColors.textMuted,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AuthStyles.fieldRadius),
      borderSide: BorderSide(color: color),
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({required this.isObscured, required this.onPressed});

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 22,
        color: AppColors.textMuted,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }
}
