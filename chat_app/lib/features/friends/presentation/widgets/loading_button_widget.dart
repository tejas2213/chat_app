import 'package:flutter/material.dart';

class LoadingButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const LoadingButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 40,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}

class LoadingIconButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;
  final Color? backgroundColor;
  final double? size;

  const LoadingIconButtonWidget({
    super.key,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.color,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: size ?? 24,
                height: size ?? 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Icon(
                icon,
                color: color,
                size: size,
              ),
      ),
    );
  }
}
