import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';

/// Glassmorphism card showing current AI monitoring status.
class SafetyStatusCard extends StatelessWidget {
  final bool isMonitoring;
  final String statusText;
  final double voiceConfidence;
  final double motionConfidence;
  final VoidCallback? onToggle;

  const SafetyStatusCard({
    super.key,
    required this.isMonitoring,
    this.statusText = 'All Clear',
    this.voiceConfidence = 0.0,
    this.motionConfidence = 0.0,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isMonitoring ? AppColors.safe : AppColors.textTertiary,
                      boxShadow: isMonitoring
                          ? [
                              BoxShadow(
                                color: AppColors.safe.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isMonitoring ? 'AI Guardian Active' : 'AI Guardian Off',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Toggle switch
                  Switch(
                    value: isMonitoring,
                    onChanged: (_) => onToggle?.call(),
                    activeThumbColor: AppColors.safe,
                    activeTrackColor: AppColors.safe.withValues(alpha: 0.3),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Status text
              Text(
                statusText,
                style: TextStyle(
                  color: isMonitoring ? AppColors.safe : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (isMonitoring) ...[
                const SizedBox(height: 16),

                // AI confidence meters
                _ConfidenceMeter(
                  label: 'Voice Analysis',
                  icon: Icons.mic,
                  value: voiceConfidence,
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 10),
                _ConfidenceMeter(
                  label: 'Motion Analysis',
                  icon: Icons.sensors,
                  value: motionConfidence,
                  activeColor: AppColors.accent,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final Color activeColor;

  const _ConfidenceMeter({
    required this.label,
    required this.icon,
    required this.value,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(
                value > 0.7 ? AppColors.emergency : activeColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(
            color: value > 0.7 ? AppColors.emergency : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
