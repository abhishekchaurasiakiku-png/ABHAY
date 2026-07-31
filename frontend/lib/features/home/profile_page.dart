import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/emergency_contact_model.dart';
import '../../shared/widgets/contact_card.dart';

/// Profile management page with emergency contacts, AI settings, and privacy.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Profile'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Center(
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'User',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'user@email.com',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Emergency Contacts
            Row(
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddContactDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Demo contacts
            ContactCard(
              contact: const EmergencyContact(
                id: '1',
                name: 'Mom',
                phone: '+91 98765 43210',
                relationship: 'Parent',
              ),
              onCall: () {},
              onMessage: () {},
              onRemove: () {},
            ),
            ContactCard(
              contact: const EmergencyContact(
                id: '2',
                name: 'Dad',
                phone: '+91 98765 43211',
                relationship: 'Parent',
              ),
              onCall: () {},
              onMessage: () {},
              onRemove: () {},
            ),
            ContactCard(
              contact: const EmergencyContact(
                id: '3',
                name: 'Best Friend',
                phone: '+91 98765 43212',
                relationship: 'Friend',
              ),
              onCall: () {},
              onMessage: () {},
              onRemove: () {},
            ),

            const SizedBox(height: 28),

            // AI Settings
            const Text(
              'AI Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            _SettingsCard(
              children: [
                _SettingsToggle(
                  icon: Icons.mic,
                  label: 'Voice Detection',
                  subtitle: 'Detect distress keywords and screams',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(color: AppColors.surfaceBorder),
                _SettingsToggle(
                  icon: Icons.sensors,
                  label: 'Motion Detection',
                  subtitle: 'Detect falls, struggles, and snatches',
                  value: true,
                  onChanged: (v) {},
                ),
                const Divider(color: AppColors.surfaceBorder),
                _SettingsSlider(
                  icon: Icons.tune,
                  label: 'Voice Sensitivity',
                  value: 0.75,
                  onChanged: (v) {},
                ),
                const Divider(color: AppColors.surfaceBorder),
                _SettingsSlider(
                  icon: Icons.tune,
                  label: 'Motion Sensitivity',
                  value: 0.70,
                  onChanged: (v) {},
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Privacy & Data
            const Text(
              'Privacy & Data',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            _SettingsCard(
              children: [
                _SettingsItem(
                  icon: Icons.privacy_tip,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                const Divider(color: AppColors.surfaceBorder),
                _SettingsItem(
                  icon: Icons.storage,
                  label: 'Clear Local Evidence',
                  onTap: () {},
                ),
                const Divider(color: AppColors.surfaceBorder),
                _SettingsItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: AppColors.emergency,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24, 24, 24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Emergency Contact',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Add Contact'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

class _SettingsSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SettingsSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              const Spacer(),
              Text(
                '${(value * 100).toInt()}%',
                style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.textPrimary,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }
}