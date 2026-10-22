import 'package:flutter/material.dart';
import '../theme/adobe_colors.dart';
import 'adobe_card.dart';

class SensorGaugeTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final double? progress; // 0.0 bis 1.0 für Fortschrittsbalken
  final Widget? trailing;
  final VoidCallback? onTap;

  const SensorGaugeTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.progress,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AdobeColors.orangeAccent;

    return AdobeCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: effectiveIconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AdobeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: AdobeColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Text(
                  value,
                  style: const TextStyle(
                    color: AdobeColors.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                backgroundColor: AdobeColors.surfaceBase,
                valueColor: AlwaysStoppedAnimation<Color>(effectiveIconColor),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TriAxisGauge extends StatelessWidget {
  final String title;
  final double x;
  final double y;
  final double z;
  final String unit;
  final IconData icon;

  const TriAxisGauge({
    super.key,
    required this.title,
    required this.x,
    required this.y,
    required this.z,
    this.unit = '',
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AdobeCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AdobeColors.orangeDim,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: AdobeColors.orangeAccent),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AdobeColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildAxisColumn('X', x, const Color(0xFFFF5252))),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisColumn('Y', y, const Color(0xFF69F0AE))),
              const SizedBox(width: 8),
              Expanded(child: _buildAxisColumn('Z', z, const Color(0xFF40C4FF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAxisColumn(String label, double val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AdobeColors.surfaceBase,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AdobeColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: const TextStyle(
                    color: AdobeColors.textMuted,
                    fontSize: 8,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            val.toStringAsFixed(2),
            style: const TextStyle(
              color: AdobeColors.textPrimary,
              fontSize: 12,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
