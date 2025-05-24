import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isEnabled;
  final int maxLines;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.isEnabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.inputLabel,
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            enabled: widget.isEnabled,
            maxLines: widget.maxLines,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            onEditingComplete: widget.onEditingComplete,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle:
                  AppTextStyles.inputText.copyWith(color: AppColors.textLight),
              prefixIcon:
                  widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
              suffixIcon: widget.suffixIcon,
              filled: true,
              fillColor:
                  widget.isEnabled ? Colors.white : AppColors.backgroundGrey,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: _isFocused
                      ? AppColors.primaryGreen
                      : AppColors.textLight.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.textLight.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
            ),
            readOnly: widget.readOnly,
            onTap: widget.onTap,
          ),
        ),
      ],
    );
  }
}
