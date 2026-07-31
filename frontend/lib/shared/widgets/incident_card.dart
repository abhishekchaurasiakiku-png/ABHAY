import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/incident_model.dart';
import 'package:intl/intl.dart';

/// Timeline-style incident history card.
class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback? onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: incident.isActive
                ? AppColors.emergency.withValues(alpha: 0.5)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline dot
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _triggerColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(
                        incident.triggerType.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Trigger type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _triggerColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            incident.triggerType.value,
                            style: TextStyle(
                              color: _triggerColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            incident.status.value,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Media indicator
                        if (incident.mediaLinks.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 14,
                                color: AppColors.textTertiary,
                              ),
                              Text(
                                '${incident.mediaLinks.length}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${incident.location.latitude.toStringAsFixed(4)}, ${incident.location.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Timestamp
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(incident.timestamp),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        if (incident.isActive) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${_formatDuration(incident.elapsed)}',
                            style: const TextStyle(
                              color: AppColors.emergency,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _triggerColor {
    switch (incident.triggerType) {
      case TriggerType.voice:
        return AppColors.primary;
      case TriggerType.motion:
        return AppColors.accent;
      case TriggerType.manual:
        return AppColors.emergency;
      case TriggerType.multiModal:
        return AppColors.warning;
    }
  }

  Color get _statusColor {
    switch (incident.status) {
      case IncidentStatus.active:
        return AppColors.emergency;
      case IncidentStatus.resolved:
        return AppColors.safe;
      case IncidentStatus.falseAlarm:
        return AppColors.textTertiary;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }
}
