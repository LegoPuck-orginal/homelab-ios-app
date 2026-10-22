import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/adobe_colors.dart';

enum AdobeButtonStyle { primary, secondary, outline }

class AdobeButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AdobeButtonStyle style;
  final bool isLoading;
  final double height;

  const AdobeButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.style = AdobeButtonStyle.primary,
    this.isLoading = false,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (style) {
      case AdobeButtonStyle.primary:
        bg = onPressed == null ? AdobeColors.surfaceElevated : AdobeColors.orangeAccent;
        fg = onPressed == null ? AdobeColors.textMuted : Colors.black;
        border = null;
        break;
      case AdobeButtonStyle.secondary:
        bg = AdobeColors.surfaceElevated;
        fg = AdobeColors.textPrimary;
        border = Border.all(color: AdobeColors.borderCard, width: 1);
        break;
      case AdobeButtonStyle.outline:
        bg = Colors.transparent;
        fg = AdobeColors.orangeAccent;
        border = Border.all(color: AdobeColors.orangeAccent.withValues(alpha: 0.6), width: 1);
        break;
    }

    return SizedBox(
      height: height,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: (onPressed == null || isLoading)
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: border,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
