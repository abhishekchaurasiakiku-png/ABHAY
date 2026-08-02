import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/sos_button.dart';

/// Emergency SOS page with hold-to-activate button, active SOS display,
/// fake call trigger, and emergency contacts quick-dial.
class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Emergency SOS'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<SosProvider>(
        builder: (context, sos, _) {
          return SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),

                // SOS Button
                Center(
                  child: SosButton(
                    isActive: sos.isSosActive,
                    onActivated: () async {
                      if (sos.isSosActive) {
                        await sos.resolveSos();
                      } else {
                        await sos.triggerManualSos();
                      }
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Status text
                Text(
                  sos.isSosActive
                      ? '🆘 SOS ACTIVE'
                      : 'Hold button for 2 seconds to activate',
                  style: TextStyle(
                    color: sos.isSosActive
                        ? AppColors.emergency
                        : AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: sos.isSosActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),

                // Active SOS info
                if (sos.isSosActive) ...[
                  const SizedBox(height: 16),
                  _ActiveSosInfo(sos: sos),
                ],

                const Spacer(flex: 1),

                // Quick action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (sos.isSosActive)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () => sos.resolveSos(notes: 'Manually resolved'),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Resolve SOS'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.safe,
                              side: const BorderSide(color: AppColors.safe),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Real Emergency Call (112 / Police)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse('tel:112');
                            try {
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not initiate emergency dialer to 112')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.call, size: 20),
                          label: const Text('Call Emergency Services (112)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emergency,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Real call button (Trusted Contacts)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showTrustedCallDialog(context);
                          },
                          icon: const Icon(Icons.phone, size: 20),
                          label: const Text('Call Trusted Contact'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceLight,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTrustedCallDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final contacts = user?.emergencyContacts ?? [];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Trusted Contact',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (contacts.isEmpty)
                const Text('No trusted contacts found. Please add them in your profile.', style: TextStyle(color: AppColors.textSecondary)),
              ...contacts.map((contact) {
                return ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    contact.phone,
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await FlutterPhoneDirectCaller.callNumber(contact.phone);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not initiate direct call')));
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveSosInfo extends StatelessWidget {
  final SosProvider sos;

  const _ActiveSosInfo({required this.sos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.emergency.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.emergency.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.emergency, size: 16),
              const SizedBox(width: 8),
              Text(
                'Duration: ${_formatDuration(sos.sosElapsed)}',
                style: const TextStyle(
                  color: AppColors.emergency,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.fiber_manual_record, color: AppColors.emergency, size: 10),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Recording audio & photos',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.fiber_manual_record, color: AppColors.safe, size: 10),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Live location streaming to secure server',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.safe, size: 14),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Real-time live location shared & direct phone calling executed automatically',
                  style: TextStyle(color: AppColors.safe, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}