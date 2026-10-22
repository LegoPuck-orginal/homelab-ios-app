import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/adobe_colors.dart';

class AdobeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  const AdobeCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final border = Border.all(
      color: borderColor ?? AdobeColors.borderCard,
      width: 1.0,
    );

    final decoration = BoxDecoration(
      color: backgroundColor ?? AdobeColors.surfaceCard,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap?.call();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            onLongPress?.call();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AdobeColors.orangeDim,
          highlightColor: AdobeColors.surfaceElevated,
          child: Container(
            padding: padding ?? const EdgeInsets.all(14.0),
            decoration: decoration,
            child: child,
          ),
        ),
      );
    }

    return Container(
      padding: padding ?? const EdgeInsets.all(14.0),
      decoration: decoration,
      child: child,
    );
  }
}
