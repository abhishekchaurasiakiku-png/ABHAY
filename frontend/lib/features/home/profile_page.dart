import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/sos_provider.dart';
import '../../shared/models/emergency_contact_model.dart';
import '../../shared/models/user_model.dart';
import '../../shared/widgets/contact_card.dart';
import '../auth/login_screen.dart';
import 'privacy_policy_page.dart';

/// Redesigned Profile Management with Glassmorphism, real avatar changes, and live AI controls.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final aiSettings = user?.aiSettings ?? const AiSettings();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D19),
      body: Stack(
        children: [
          // 1. Aurora Background
          const _AuroraBackground(),

          // 2. Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Guardian Profile ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Personalized Security & Live AI Detection Sensors',
                    style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Hero Profile Identity Card
                  _buildProfileCard(context, user),
                  const SizedBox(height: 28),

                  // Future-Oriented Emergency & Safe Zone Details Card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Emergency & Medical Profile 🏥',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showEditProfileModal(context, user),
                        icon: const Icon(Icons.edit_outlined, color: Color(0xFF4DEEEA), size: 16),
                        label: const Text('Edit Details', style: TextStyle(color: Color(0xFF4DEEEA), fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vital paramedical triage & smart home safe-zone geofencing',
                    style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _buildEmergencyMedicalCard(context, user),
                  const SizedBox(height: 28),

                  // Real-Time AI Guardian Detection Settings
                  const Text(
                    'Real-Time AI Detection Settings 🤖',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Adjust hardware sensor thresholds & active monitoring',
                    style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  _buildAiSettingsCard(context, aiSettings),
                  const SizedBox(height: 28),

                  // Emergency Contacts Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: const Text(
                          'Trusted Emergency Contacts 👥',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showAddContactBottomSheet(context),
                        icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF4DEEEA), size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _buildContactsSection(context, user?.emergencyContacts ?? []),
                  const SizedBox(height: 28),

                  // Trust & Privacy Policy
                  const Text(
                    'Trust & Data Transparency 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  _GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF3B82F6).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.privacy_tip_rounded, color: Color(0xFF3B82F6), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Privacy & Safety Data Policy', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                                SizedBox(height: 2),
                                Text('How your live location and audio data are shielded', style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 11)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Logout Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 22),
                      label: const Text('Sign Out from SafeHer-AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1E56).withValues(alpha: 0.85),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ),

                  // Bottom space for floating navigation bar
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return _GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      borderColor: const Color(0xFF6C63FF).withValues(alpha: 0.4),
      glowColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
      child: Row(
        children: [
          // Avatar with clickable camera/preset modification
          GestureDetector(
            onTap: () => _showAvatarPicker(context),
            child: Stack(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFFFF4D9D), Color(0xFF4DEEEA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4D9D).withValues(alpha: 0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF161929),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _renderAvatarContent(user?.profileImage, user?.name),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4DEEEA),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0B0D19), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0B0D19), size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Protected Guardian',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email_outlined, color: Color(0xFF4DEEEA), size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user?.email ?? 'guardian@safeher.ai',
                        style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, color: Color(0xFFFF4D9D), size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user?.phone ?? '+91 99999 99999',
                        style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 13, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showEditProfileModal(context, user),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.edit_note_rounded, color: Color(0xFF4DEEEA), size: 24),
            ),
            tooltip: 'Edit Profile & Future-Oriented Details',
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyMedicalCard(BuildContext context, UserModel? user) {
    return _GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      borderColor: const Color(0xFFFF4D9D).withValues(alpha: 0.35),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D9D).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF4D9D), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Blood Group & Vital Info', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      user?.bloodGroup?.isNotEmpty == true ? 'Blood Type: ${user!.bloodGroup!}' : 'Blood Group: Not set (Tap Edit)',
                      style: const TextStyle(color: Color(0xFF4DEEEA), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.medical_services_rounded, color: Color(0xFF6C63FF), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medical Notes / Allergies (ER Ready)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      user?.medicalNotes?.isNotEmpty == true ? user!.medicalNotes! : 'No allergies or medical notes recorded yet.',
                      style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF4DEEEA).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.home_work_rounded, color: Color(0xFF4DEEEA), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Home Safe Zone Geofence Address', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                      user?.homeSafeZone?.isNotEmpty == true ? user!.homeSafeZone! : 'Set residence address for automated arrival check-ins.',
                      style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, UserModel? user) {
    final nameCtrl = TextEditingController(text: user?.name ?? '');
    final phoneCtrl = TextEditingController(text: user?.phone ?? '');
    final bloodCtrl = TextEditingController(text: user?.bloodGroup ?? '');
    final medicalCtrl = TextEditingController(text: user?.medicalNotes ?? '');
    final safeZoneCtrl = TextEditingController(text: user?.homeSafeZone ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161929),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Edit Future-Oriented Profile ✏️',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Update real-time display name, emergency phone, and future medical/geofence alerts.',
                  style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 13),
                ),
                const SizedBox(height: 20),
                _buildModalTextField(label: 'Full Display Name', controller: nameCtrl, icon: Icons.person_outline_rounded),
                const SizedBox(height: 14),
                _buildModalTextField(label: 'Emergency Contact Phone', controller: phoneCtrl, icon: Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                const SizedBox(height: 14),
                _buildModalTextField(label: 'Blood Group (e.g. O+, B-, AB+)', controller: bloodCtrl, icon: Icons.favorite_outline_rounded),
                const SizedBox(height: 14),
                _buildModalTextField(label: 'Medical Notes & Allergies (ER Support)', controller: medicalCtrl, icon: Icons.medical_information_outlined, maxLines: 2),
                const SizedBox(height: 14),
                _buildModalTextField(label: 'Home Geofence Safe Zone Address', controller: safeZoneCtrl, icon: Icons.my_location_rounded, maxLines: 2),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Display Name cannot be empty')),
                        );
                        return;
                      }
                      Navigator.pop(ctx);
                      await context.read<AuthProvider>().updateProfileDetails(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            bloodGroup: bloodCtrl.text.trim(),
                            medicalNotes: medicalCtrl.text.trim(),
                            homeSafeZone: safeZoneCtrl.text.trim(),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Profile details & future safety settings updated in real time!'),
                            backgroundColor: Color(0xFF00E676),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 22),
                    label: const Text('Save Real-Time Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DEEEA),
                      foregroundColor: const Color(0xFF0A0E21),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
            filled: true,
            fillColor: const Color(0xFF22263A),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4DEEEA), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderAvatarContent(String? profileImage, String? name) {
    if (profileImage != null && profileImage.isNotEmpty) {
      if (profileImage.startsWith('base64:')) {
        try {
          final bytes = base64Decode(profileImage.substring(7));
          return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
        } catch (_) {}
      } else if (profileImage.startsWith('preset:')) {
        final iconType = profileImage.substring(7);
        IconData iconData = Icons.shield_rounded;
        Color iconColor = const Color(0xFF4DEEEA);
        if (iconType == 'queen') {
          iconData = Icons.workspace_premium_rounded;
          iconColor = const Color(0xFFFF4D9D);
        } else if (iconType == 'angel') {
          iconData = Icons.health_and_safety_rounded;
          iconColor = const Color(0xFFFFB88C);
        } else if (iconType == 'star') {
          iconData = Icons.auto_awesome_rounded;
          iconColor = const Color(0xFF6C63FF);
        }
        return Center(child: Icon(iconData, color: iconColor, size: 38));
      }
    }
    // Default initial
    return Center(
      child: Text(
        (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'G',
        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16192B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Personalize Your Profile Avatar 🎨', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF4DEEEA).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF4DEEEA)),
              ),
              title: const Text('Pick from Device Gallery / Camera', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: const Text('Uploads real photo securely to your account', style: TextStyle(color: Colors.white60, fontSize: 11)),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 400, maxHeight: 400);
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  final base64Img = 'base64:${base64Encode(bytes)}';
                  if (context.mounted) {
                    await context.read<AuthProvider>().updateProfileImage(base64Img);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile photo updated successfully in real time!')));
                  }
                }
              },
            ),
            const Divider(color: Colors.white12),
            const Text('Or Choose a Guardian Icon Preset:', style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 13)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AvatarPresetButton(label: 'Shield', icon: Icons.shield_rounded, color: const Color(0xFF4DEEEA), preset: 'preset:shield', context: context, dialogContext: ctx),
                _AvatarPresetButton(label: 'Queen', icon: Icons.workspace_premium_rounded, color: const Color(0xFFFF4D9D), preset: 'preset:queen', context: context, dialogContext: ctx),
                _AvatarPresetButton(label: 'Angel', icon: Icons.health_and_safety_rounded, color: const Color(0xFFFFB88C), preset: 'preset:angel', context: context, dialogContext: ctx),
                _AvatarPresetButton(label: 'Star', icon: Icons.auto_awesome_rounded, color: const Color(0xFF6C63FF), preset: 'preset:star', context: context, dialogContext: ctx),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAiSettingsCard(BuildContext context, AiSettings settings) {
    return _GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      borderColor: const Color(0xFF4DEEEA).withValues(alpha: 0.35),
      glowColor: const Color(0xFF4DEEEA).withValues(alpha: 0.12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice Distress Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF4DEEEA).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.mic_rounded, color: Color(0xFF4DEEEA), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Voice Distress Recognition', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Listens for "Help me" / "Bachao"', style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: settings.voiceDetectionEnabled,
                activeColor: const Color(0xFF4DEEEA),
                onChanged: (val) {
                  final updated = AiSettings(
                    voiceDetectionEnabled: val,
                    motionDetectionEnabled: settings.motionDetectionEnabled,
                    voiceSensitivity: settings.voiceSensitivity,
                    motionSensitivity: settings.motionSensitivity,
                    distressKeywords: settings.distressKeywords,
                  );
                  context.read<AuthProvider>().updateAiSettings(updated);
                  if (val || settings.motionDetectionEnabled) {
                    context.read<SosProvider>().startAiMonitoring();
                  } else {
                    context.read<SosProvider>().stopAiMonitoring();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Voice Sensitivity: ${(settings.voiceSensitivity * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Slider(
            value: settings.voiceSensitivity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            activeColor: const Color(0xFF4DEEEA),
            inactiveColor: Colors.white12,
            onChanged: (val) {
              final updated = AiSettings(
                voiceDetectionEnabled: settings.voiceDetectionEnabled,
                motionDetectionEnabled: settings.motionDetectionEnabled,
                voiceSensitivity: val,
                motionSensitivity: settings.motionSensitivity,
                distressKeywords: settings.distressKeywords,
              );
              context.read<AuthProvider>().updateAiSettings(updated);
            },
          ),
          const Divider(color: Colors.white12, height: 24),

          // Motion & Fall Detection Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFF4D9D).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.sensors_rounded, color: Color(0xFFFF4D9D), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Motion & Fall Detection', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Detects rapid impacts & struggles', style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: settings.motionDetectionEnabled,
                activeColor: const Color(0xFFFF4D9D),
                onChanged: (val) {
                  final updated = AiSettings(
                    voiceDetectionEnabled: settings.voiceDetectionEnabled,
                    motionDetectionEnabled: val,
                    voiceSensitivity: settings.voiceSensitivity,
                    motionSensitivity: settings.motionSensitivity,
                    distressKeywords: settings.distressKeywords,
                  );
                  context.read<AuthProvider>().updateAiSettings(updated);
                  if (val || settings.voiceDetectionEnabled) {
                    context.read<SosProvider>().startAiMonitoring();
                  } else {
                    context.read<SosProvider>().stopAiMonitoring();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Motion Threshold Sensitivity: ${(settings.motionSensitivity * 100).toInt()}%', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Slider(
            value: settings.motionSensitivity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            activeColor: const Color(0xFFFF4D9D),
            inactiveColor: Colors.white12,
            onChanged: (val) {
              final updated = AiSettings(
                voiceDetectionEnabled: settings.voiceDetectionEnabled,
                motionDetectionEnabled: settings.motionDetectionEnabled,
                voiceSensitivity: settings.voiceSensitivity,
                motionSensitivity: val,
                distressKeywords: settings.distressKeywords,
              );
              context.read<AuthProvider>().updateAiSettings(updated);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactsSection(BuildContext context, List<EmergencyContact> contacts) {
    if (contacts.isEmpty) {
      return _GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(28),
        borderColor: const Color(0xFFFFB88C).withValues(alpha: 0.35),
        child: Column(
          children: [
            const Icon(Icons.contacts_rounded, color: Color(0xFFFFB88C), size: 48),
            const SizedBox(height: 12),
            const Text('No Emergency Contacts Saved', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text(
              'Add trusted guardians so SafeHer-AI can automatically alert and call them during an SOS emergency.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddContactBottomSheet(context),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Guardian Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4DEEEA),
                foregroundColor: const Color(0xFF0B0D19),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _GlassCard(
          borderRadius: 22,
          padding: const EdgeInsets.all(16),
          borderColor: const Color(0xFFFF4D9D).withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D9D).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFF4D9D).withValues(alpha: 0.5)),
                    ),
                    child: Center(
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'G',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, color: Color(0xFFFF4D9D), size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(contact.phone, style: const TextStyle(color: Color(0xFFD0D3E5), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        if (contact.email.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.email_rounded, color: Color(0xFF4DEEEA), size: 13),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(contact.email, style: const TextStyle(color: Color(0xFFB0B3C7), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.white54, size: 20),
                    onPressed: () {
                      context.read<AuthProvider>().removeEmergencyContact(contact.id.isNotEmpty ? contact.id : contact.name);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact removed from guardian list')));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF00E676),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: const Text('Call', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      try {
                        await FlutterPhoneDirectCaller.callNumber(contact.phone);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not initiate direct call')));
                      }
                    },
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                      foregroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.message_rounded, size: 16),
                    label: const Text('SMS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      final uri = Uri.parse('sms:${contact.phone}?body=EMERGENCY ALERT: I need immediate assistance from SafeHer-AI!');
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  if (contact.email.isNotEmpty)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                        foregroundColor: const Color(0xFF4DEEEA),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.email_rounded, size: 16),
                      label: const Text('Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        final uri = Uri.parse('mailto:${contact.email}?subject=EMERGENCY SOS ALERT&body=EMERGENCY ALERT: I need immediate assistance! Please check my real-time GPS coordinates!');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddContactBottomSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF16192B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Trusted Guardian 🛡️', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Guardian Name',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.person, color: Color(0xFF4DEEEA)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Phone Number (with country code e.g. +91)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFFFF4D9D)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please enter phone number' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Guardian Email Address (For Live GPS Alert)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFF6C63FF)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4DEEEA),
                      foregroundColor: const Color(0xFF0B0D19),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await context.read<AuthProvider>().addEmergencyContact(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              email: emailController.text.trim(),
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    child: const Text('Save Emergency Guardian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPresetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String preset;
  final BuildContext context;
  final BuildContext dialogContext;

  const _AvatarPresetButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.preset,
    required this.context,
    required this.dialogContext,
  });

  @override
  Widget build(BuildContext buildContext) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(dialogContext);
        await context.read<AuthProvider>().updateProfileImage(preset);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✨ Profile avatar set to $label!')));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: color, width: 1.5)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -50,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF6C63FF).withValues(alpha: 0.35), const Color(0xFF6C63FF).withValues(alpha: 0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          left: -70,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFFFF4D9D).withValues(alpha: 0.28), const Color(0xFFFF4D9D).withValues(alpha: 0.0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;

  const _GlassCard({required this.child, this.borderRadius = 28, this.padding = const EdgeInsets.all(20), this.borderColor, this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null ? [BoxShadow(color: glowColor!, blurRadius: 24, offset: const Offset(0, 6))] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1D32).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.15), width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}