import 'package:flutter/material.dart';
import '../theme/adobe_colors.dart';

class LiveStatusIndicator extends StatelessWidget {
  final bool? isOnline;
  final int? latencyMs;
  final bool showLabel;

  const LiveStatusIndicator({
    super.key,
    required this.isOnline,
    this.latencyMs,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    String statusText;

    if (isOnline == null) {
      dotColor = AdobeColors.textMuted;
      statusText = 'Prüfen...';
    } else if (isOnline == true) {
      dotColor = AdobeColors.statusOnline;
      statusText = latencyMs != null ? '${latencyMs}ms' : 'Online';
    } else {
      dotColor = AdobeColors.statusOffline;
      statusText = 'Offline';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: isOnline == true
                ? [
                    BoxShadow(
                      color: AdobeColors.statusOnline.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 5),
          Text(
            statusText,
            style: TextStyle(
              color: isOnline == true ? AdobeColors.textSecondary : AdobeColors.textMuted,
              fontSize: 10,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
