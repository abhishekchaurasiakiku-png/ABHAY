import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/emergency_contact_model.dart';

/// Emergency contact card with quick actions.
class ContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final VoidCallback? onRemove;

  const ContactCard({
    super.key,
    required this.contact,
    this.onCall,
    this.onMessage,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${contact.relationship} • ${contact.phone}',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Quick actions
            if (onCall != null)
              _ActionIcon(
                icon: Icons.call,
                color: AppColors.safe,
                onTap: onCall!,
              ),
            if (onMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _ActionIcon(
                  icon: Icons.message,
                  color: AppColors.primary,
                  onTap: onMessage!,
                ),
              ),
            if (onRemove != null)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _ActionIcon(
                  icon: Icons.close,
                  color: AppColors.emergency,
                  onTap: onRemove!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
