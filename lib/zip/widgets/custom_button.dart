// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final double? width;
  final double height;
  final List<Color>? gradientColors;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height = 52,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    final isDisabled = onPressed == null || isLoading;

    final Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : width,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: colors.gradient,
              color: colors.gradient == null ? colors.background : null,
              borderRadius: BorderRadius.circular(14),
              border: colors.border,
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: (colors.gradient?.colors.first ??
                                colors.background ??
                                Colors.transparent)
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: AnimatedOpacity(
              opacity: isDisabled ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ] else ...[
                    if (prefixIcon != null) ...[
                      Icon(prefixIcon, color: colors.foreground, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(text,
                        style: AppTextStyles.buttonText
                            .copyWith(color: colors.foreground)),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(suffixIcon, color: colors.foreground, size: 20),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return button;
  }

  _ButtonColors _resolveColors() {
    if (gradientColors != null) {
      return _ButtonColors(
        gradient: LinearGradient(
          colors: gradientColors!,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        foreground: Colors.white,
      );
    }
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          gradient: AppColors.accentGradient,
          foreground: Colors.white,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          background: AppColors.surfaceVariant,
          foreground: AppColors.textPrimary,
        );
      case ButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.accent,
          border: Border.all(color: AppColors.accent, width: 1.5),
        );
      case ButtonVariant.ghost:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.textSecondary,
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.error,
          foreground: Colors.white,
        );
    }
  }
}

class _ButtonColors {
  final LinearGradient? gradient;
  final Color? background;
  final Color foreground;
  final Border? border;
  _ButtonColors(
      {this.gradient, this.background, required this.foreground, this.border});
}

// ─── Organizer Variant (purple gradient) ────────────────────
class OrganizerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;

  const OrganizerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      prefixIcon: prefixIcon,
      gradientColors: const [
        AppColors.organizerAccent,
        AppColors.organizerDark
      ],
    );
  }
}
