import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isFullWidth;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final double? width;
  final EdgeInsets? padding;
  final double borderRadius;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
    this.isLoading = false,
    this.icon,
    this.height = 48.0,
    this.width,
    this.padding,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  ButtonStyle _getButtonStyle() {
    switch (type) {
      case ButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: AppTextStyles.buttonText,
          elevation: 0,
        );
      case ButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryOrange,
          foregroundColor: Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: AppTextStyles.buttonText,
          elevation: 0,
        );
      case ButtonType.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryGreen,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(color: AppColors.primaryGreen),
          ),
          textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.primaryGreen),
          elevation: 0,
        );
      case ButtonType.text:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryGreen,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.primaryGreen),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
    }
  }
}
