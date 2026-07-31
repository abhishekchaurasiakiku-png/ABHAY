import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/services/ai_engine.dart';
import '../../shared/widgets/safety_status_card.dart';
import '../../shared/widgets/ai_status_indicator.dart';

/// Dashboard home page with AI status, SOS quick access, and activity feed.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, User 👋',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay safe today',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Consumer<SosProvider>(
                    builder: (_, sos, _) => AiStatusIndicator(
                      threatLevel: sos.threatLevel,
                      isActive: sos.isAiMonitoring,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Safety status card
              Consumer<SosProvider>(
                builder: (_, sos, _) => SafetyStatusCard(
                  isMonitoring: sos.isAiMonitoring,
                  statusText: _getStatusText(sos.threatLevel),
                  voiceConfidence: sos.lastAssessment?.voiceEvent?.confidence ?? 0.0,
                  motionConfidence: sos.lastAssessment?.motionEvent?.confidence ?? 0.0,
                  onToggle: () {
                    if (sos.isAiMonitoring) {
                      sos.stopAiMonitoring();
                    } else {
                      sos.startAiMonitoring();
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.phone,
                      label: 'Fake Call',
                      color: AppColors.accent,
                      onTap: () {
                        context.read<SosProvider>().triggerFakeCall();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.share_location,
                      label: 'Share Location',
                      color: AppColors.info,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.route,
                      label: 'Safe Route',
                      color: AppColors.safe,
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Safety Tips
              const Text(
                'Safety Tips',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              _SafetyTipCard(
                icon: Icons.mic,
                title: 'Voice Detection Active',
                description: 'Say "Help me" or "Bachao" to auto-trigger SOS',
                color: AppColors.primary,
              ),

              const SizedBox(height: 10),

              _SafetyTipCard(
                icon: Icons.sensors,
                title: 'Motion Monitoring',
                description: 'Falls and struggles are automatically detected',
                color: AppColors.accent,
              ),

              const SizedBox(height: 10),

              _SafetyTipCard(
                icon: Icons.contacts,
                title: 'Add Emergency Contacts',
                description: 'Go to Profile → Contacts to set up your guardians',
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(ThreatLevel level) {
    switch (level) {
      case ThreatLevel.safe:
        return 'All Clear — No threats detected';
      case ThreatLevel.low:
        return 'Minor signal detected — Monitoring';
      case ThreatLevel.medium:
        return '⚠️ Moderate concern — Stay alert';
      case ThreatLevel.high:
        return '🚨 High confidence distress detected';
      case ThreatLevel.critical:
        return '🆘 CRITICAL — Emergency triggered';
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _SafetyTipCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}