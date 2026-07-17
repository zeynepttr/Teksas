import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum CustomButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = CustomButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 54.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext WidgetContext) {
    final theme = Theme.of(WidgetContext);
    
    Color getBgColor() {
      if (onPressed == null) return Colors.grey.shade800;
      switch (type) {
        case CustomButtonType.primary:
          return AppColors.buttonDark;
        case CustomButtonType.secondary:
          return AppColors.buttonLight;
        case CustomButtonType.text:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (onPressed == null) return Colors.grey.shade500;
      switch (type) {
        case CustomButtonType.primary:
          return Colors.white;
        case CustomButtonType.secondary:
          return AppColors.darkGreen;
        case CustomButtonType.text:
          return AppColors.accent;
      }
    }

    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, color: getTextColor(), size: 20),
          const SizedBox(width: 8),
        ],
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(getTextColor()),
            ),
          )
        else
          Text(
            text,
            style: TextStyle(
              fontFamily: 'DINPro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: getTextColor(),
            ),
          ),
      ],
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: (type == CustomButtonType.primary && onPressed != null) 
            ? AppColors.buttonGradient 
            : null,
        boxShadow: (type == CustomButtonType.primary && onPressed != null)
            ? [
                BoxShadow(
                  color: AppColors.buttonDark.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: (type == CustomButtonType.primary && onPressed != null)
              ? Colors.transparent
              : getBgColor(),
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.grey.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: content,
      ),
    );
  }
}
