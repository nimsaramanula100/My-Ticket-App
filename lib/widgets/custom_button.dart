// lib/widgets/custom_button.dart
// ─────────────────────────────────────────────────────────────────────────────
// CustomButton | අභිරුචි බොත්තම (Generic Styling Button Widget)
// A versatile custom button supporting gradients, outlines, icons, and loading indicators.
// අනුක්‍රමණ (Gradients), මායිම් (Outlines), අයිකන සහ දත්ත පූරණ (Loading) සලකුණු සහිත බහුකාර්ය බොත්තමකි.
// Also includes OrganizerButton subclass designed with specific brand purple gradients.
// දම් පැහැති විශේෂ සංවිධායක බොත්තම (OrganizerButton) ද මෙහි ඇතුළත් වේ.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../theme/color_palette.dart';
import '../theme/app_text_styles.dart';

// Enum defining styling variants of the button
// බොත්තම හැඩගන්වන විවිධ ආකාර අර්ථ දක්වන Enum එකක්
enum ButtonVariant { primary, secondary, outline, ghost, danger }

// ─── CustomButton Class | පොදු බොත්තම් පන්තිය ──────────────────────────────────
class CustomButton extends StatelessWidget {
  final String text;                   // Label displayed on button | බොත්තම මත පෙන්වන පෙළ
  final VoidCallback? onPressed;       // Callback function on tap (null disables button) | ක්ලික් කළ විට ධාවනය වන ශ්‍රිතය (null නම් බොත්තම අක්‍රීය වේ)
  final ButtonVariant variant;         // Style theme configuration | බොත්තම හැඩගන්වන ක්‍රමය
  final bool isLoading;                // Spinner state toggler | දත්ත පූරණය වන බව පෙන්වන තත්වය
  final bool isFullWidth;              // Expand to fill horizontal space | තිරයේ සම්පූර්ණ පළල ගන්නා ලෙස සැකසීම
  final IconData? prefixIcon;          // Optional start icon | වම් පසින් පෙන්වන විකල්ප අයිකනය
  final IconData? suffixIcon;          // Optional end icon | දකුණු පසින් පෙන්වන විකල්ප අයිකනය
  final double? width;                 // Static width if isFullWidth is false | බොත්තම සඳහා වන නිශ්චිත පළල
  final double height;                 // Height of the button container | බොත්තමේ උස
  final List<Color>? gradientColors;   // Custom gradient override list | අභිරුචි වර්ණ අනුක්‍රමණ ලැයිස්තුව

  // Constructor | Constructor (ඉදිකිරීමේ ශ්‍රිතය)
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
    // Resolve colors based on current theme, status, and custom overrides
    // වත්මන් තේමාව, තත්වය සහ වර්ණ සැකසුම් මත බොත්තමේ වර්ණය තීරණය කරයි
    final colors = _resolveColors();
    final isDisabled = onPressed == null || isLoading;

    final Widget button = SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : width,
      child: Material(
        color: Colors.transparent, // Disable default material background | පෙරනිමි පසුබිම සඟවයි
        child: InkWell(
          onTap: isDisabled ? null : onPressed, // Disable gestures if disabled | අක්‍රීය නම් ක්ලික් සීමා කරයි
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: colors.gradient,
              color: colors.gradient == null ? colors.background : null,
              borderRadius: BorderRadius.circular(14),
              border: colors.border,
              // Soft glow shadow matching the primary color (disabled gets no shadow)
              // බොත්තමේ පසුබිම් වර්ණයට ගැළපෙන සෙවනැලි ආචරණය (අක්‍රීය බොත්තම් වල සෙවනැල්ලක් නැත)
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
              opacity: isDisabled ? 0.5 : 1.0, // Fade out button when disabled | අක්‍රීය විට මඳක් අඳුරු කරයි
              duration: const Duration(milliseconds: 200),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  // 1. Loading state view | 1. දත්ත පූරණ (Loading) දසුන
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
                  ] 
                  // 2. Default state view (Text + optional icons)
                  // 2. සාමාන්‍ය දසුන (පෙළ සහ විකල්ප අයිකන)
                  else ...[
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

  // ─── _resolveColors: Decides colors per variant | වර්ණ තීරණය කිරීමේ ශ්‍රිතය ───────────
  // Evaluates options, custom gradients, and returns styling container.
  // බොත්තම හැඩගන්වන ආකාරය (Variant) අනුව ඊට ගැළපෙන වර්ණ කට්ටලය තීරණය කරයි.
  _ButtonColors _resolveColors() {
    // Apply custom gradient overrides first | අභිරුචි වර්ණ අනුක්‍රමණය පළමුව යොදයි
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
    
    // Resolve standard variant styles | සාමාන්‍ය ආකාර අනුව වර්ණ තෝරා දීම
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

// ─── _ButtonColors: Internally holds resolved configurations | වර්ණ දත්ත දරන පන්තිය ───
class _ButtonColors {
  final LinearGradient? gradient;
  final Color? background;
  final Color foreground;
  final Border? border;
  _ButtonColors(
      {this.gradient, this.background, required this.foreground, this.border});
}

// ─── Organizer Variant (purple gradient) | සංවිධායක බොත්තම් පන්තිය ───────────────────────
// Wraps CustomButton configured with purple branded colors.
// සංවිධායක අංශය සඳහා වන දම් පැහැති විශේෂිත බොත්තමකි.
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
