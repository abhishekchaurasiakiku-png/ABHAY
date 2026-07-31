import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ai_engine.dart';

/// Animated indicator showing AI threat level.
class AiStatusIndicator extends StatelessWidget {
  final ThreatLevel threatLevel;
  final bool isActive;

  const AiStatusIndicator({
    super.key,
    required this.threatLevel,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated dot
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isActive ? 1.0 : 0.5),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dotColor.withValues(alpha: value),
                  boxShadow: isActive && threatLevel != ThreatLevel.safe
                      ? [
                          BoxShadow(
                            color: _dotColor.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    if (!isActive) return 'Offline';
    switch (threatLevel) {
      case ThreatLevel.safe:
        return 'Safe';
      case ThreatLevel.low:
        return 'Alert';
      case ThreatLevel.medium:
        return 'Caution';
      case ThreatLevel.high:
        return 'Danger';
      case ThreatLevel.critical:
        return 'CRITICAL';
    }
  }

  Color get _dotColor {
    if (!isActive) return AppColors.textTertiary;
    switch (threatLevel) {
      case ThreatLevel.safe:
        return AppColors.safe;
      case ThreatLevel.low:
        return AppColors.warning;
      case ThreatLevel.medium:
        return AppColors.warning;
      case ThreatLevel.high:
        return AppColors.emergency;
      case ThreatLevel.critical:
        return AppColors.sosPulse;
    }
  }

  Color get _textColor {
    if (!isActive) return AppColors.textTertiary;
    switch (threatLevel) {
      case ThreatLevel.safe:
        return AppColors.safe;
      case ThreatLevel.low:
        return AppColors.warning;
      case ThreatLevel.medium:
        return AppColors.warning;
      case ThreatLevel.high:
        return AppColors.emergency;
      case ThreatLevel.critical:
        return AppColors.sosPulse;
    }
  }

  Color get _backgroundColor {
    return _dotColor.withValues(alpha: 0.1);
  }

  Color get _borderColor {
    return _dotColor.withValues(alpha: 0.3);
  }
}
