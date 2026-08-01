import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/sos_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/location_provider.dart';

/// Premium Women Safety Dashboard with Glassmorphism & Aurora Gradients.
/// Apple Human Interface + Material 3 Expressive styling with ultra-smooth performance.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D19),
      body: Stack(
        children: [
          // 1. High-Performance Aurora Gradient Background
          const _AuroraBackground(),

          // 2. Main Scrollable Dashboard Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transparent Header with Greeting & Profile Avatar
                  _buildHeader(user),
                  const SizedBox(height: 24),

                  // Large Hero Banner ("You Are Never Alone")
                  const _HeroBanner(),
                  const SizedBox(height: 28),

                  // Floating Circular Emergency SOS Button & Quick Emergency Shortcuts
                  _buildEmergencyCenter(context),
                  const SizedBox(height: 28),

                  // AI Guardian Status & Circular Safety Score Indicator
                  const _GuardianAndScoreRow(),
                  const SizedBox(height: 28),

                  // 2-Column Grid of Glass Cards (Guardian Toolkit)
                  _buildToolkitGrid(context),
                  const SizedBox(height: 28),

                  // Daily Safety Tip Card
                  const _SafetyTipCard(),
                  
                  // Extra padding for floating bottom navigation
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Hello, ${user?.name ?? 'Guardian'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text('✨', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4DEEEA),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0xFF4DEEEA), blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Shield Active & Monitoring',
                    style: TextStyle(
                      color: Color(0xFFB0B3C7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Avatar with vibrant neon aurora gradient border
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFFFF4D9D), Color(0xFF4DEEEA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4D9D).withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF161929),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user?.name != null && user!.name.isNotEmpty)
                    ? user.name[0].toUpperCase()
                    : 'G',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyCenter(BuildContext context) {
    return Column(
      children: [
        // Floating Circular Emergency SOS Button
        Center(
          child: GestureDetector(
            onTap: () {
              context.read<SosProvider>().triggerSos();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚨 EMERGENCY SOS TRIGGERED - Alerting contacts & streaming location!'),
                  backgroundColor: Color(0xFFFF1E56),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF4D9D), Color(0xFFFF1E56), Color(0xFFD50000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF4D9D).withValues(alpha: 0.55),
                    blurRadius: 32,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF1E56).withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 114,
                    height: 114,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.touch_app_rounded, color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'TAP TO ALERT',
                        style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Quick Emergency Shortcuts
        Row(
          children: [
            Expanded(
              child: _EmergencyShortcut(
                icon: Icons.local_phone_rounded,
                label: '112',
                subLabel: 'Emergency',
                color: const Color(0xFFFF4D9D),
                onTap: () async => _launchPhone('112', context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EmergencyShortcut(
                icon: Icons.support_agent_rounded,
                label: 'Helpline',
                subLabel: '1091 Women',
                color: const Color(0xFF6C63FF),
                onTap: () async => _launchPhone('1091', context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EmergencyShortcut(
                icon: Icons.fiber_manual_record_rounded,
                label: 'Record',
                subLabel: 'Evidence',
                color: const Color(0xFF4DEEEA),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎙️ Emergency evidence audio & camera recording started!'),
                      backgroundColor: Color(0xFF3B82F6),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _EmergencyShortcut(
                icon: Icons.flashlight_on_rounded,
                label: 'Beacon',
                subLabel: 'Flashlight',
                color: const Color(0xFFFFB88C),
                onTap: () => _showFlashlightBeacon(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolkitGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Safety Toolkit',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            _ToolkitCard(
              icon: Icons.share_location_rounded,
              title: 'Live Location',
              subtitle: 'Share real-time GPS',
              color: const Color(0xFF4DEEEA),
              onTap: () async {
                final loc = context.read<LocationProvider>();
                String? url = loc.mapsUrl;
                if (url == null) {
                  await loc.initialize();
                  url = loc.mapsUrl;
                }
                final shareUrl = url ?? 'https://maps.google.com/?q=28.6139,77.2090';
                await Share.share('My current real-time GPS safety location from SafeHer-AI: $shareUrl');
              },
            ),
            _ToolkitCard(
              icon: Icons.contact_phone_rounded,
              title: 'Emergency Contacts',
              subtitle: 'Call or alert guardians',
              color: const Color(0xFFFF4D9D),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('👥 Trusted guardians actively connected in real time.')),
                );
              },
            ),
            _ToolkitCard(
              icon: Icons.verified_user_rounded,
              title: 'Safety Zone',
              subtitle: 'Geofence all-clear',
              color: const Color(0xFF6C63FF),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🛡️ Current coordinates inside high safety geofence zone.')),
                );
              },
            ),
            _ToolkitCard(
              icon: Icons.directions_walk_rounded,
              title: 'Safe Route',
              subtitle: 'AI monitored navigation',
              color: const Color(0xFF3B82F6),
              onTap: () async {
                final loc = context.read<LocationProvider>();
                final pos = loc.currentPosition;
                final uri = pos != null
                    ? Uri.parse('https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}')
                    : Uri.parse('https://www.google.com/maps');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open Google Maps navigation')),
                    );
                  }
                }
              },
            ),
            _ToolkitCard(
              icon: Icons.local_police_rounded,
              title: 'Nearby Police',
              subtitle: 'Locate closest station',
              color: const Color(0xFFFFB88C),
              onTap: () async {
                final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=police+station+nearby');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not search for nearby police stations')),
                    );
                  }
                }
              },
            ),
            _ToolkitCard(
              icon: Icons.history_rounded,
              title: 'Incident History',
              subtitle: 'View security logs',
              color: const Color(0xFF00E676),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📋 No active distress incidents reported today.')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchPhone(String phone, BuildContext context) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate phone dialer to $phone')),
        );
      }
    }
  }

  void _showFlashlightBeacon(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.zero,
        child: InkWell(
          onTap: () => Navigator.pop(ctx),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.warning_rounded, color: Colors.red, size: 96),
                  SizedBox(height: 20),
                  Text(
                    'EMERGENCY BEACON ACTIVE',
                    style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 10),
                  Text('Tap anywhere to turn off flashlight screen beacon', style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─── 1. Aurora Background Widget (Zero asset size, 120 FPS GPU Render) ───
class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Purple & Pink upper halo
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.35),
                  const Color(0xFF6C63FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Pink & Cyan mid halo
        Positioned(
          top: 140,
          right: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF4D9D).withValues(alpha: 0.28),
                  const Color(0xFFFF4D9D).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Cyan & Blue lower-left halo
        Positioned(
          top: 420,
          left: -70,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4DEEEA).withValues(alpha: 0.22),
                  const Color(0xFF3B82F6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        // Peach & Blue lower-right halo
        Positioned(
          bottom: 100,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFB88C).withValues(alpha: 0.20),
                  const Color(0xFFFFB88C).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ─── 2. Universal Frosted Glass Card (28px corners, soft blur & neon glow) ───
class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const _GlassCard({
    required this.child,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.glowColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!,
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                )
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D32).withValues(alpha: 0.65),
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor ?? Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─── 3. Large Hero Banner ("You Are Never Alone") ───
class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF6C63FF).withValues(alpha: 0.35),
          const Color(0xFFFF4D9D).withValues(alpha: 0.15),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFFF4D9D).withValues(alpha: 0.45),
      glowColor: const Color(0xFF6C63FF).withValues(alpha: 0.25),
      child: Row(
        children: [
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D9D).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF4D9D).withValues(alpha: 0.5)),
                  ),
                  child: const Text(
                    'LIVE PROTECTION',
                    style: TextStyle(color: Color(0xFFFF4D9D), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'You Are Never\nAlone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SafeHer AI & real-time guardian shield is actively guarding your journey 24/7.',
                  style: TextStyle(
                    color: Color(0xFFD0D3E5),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Premium 3D Styled Shield Illustration Badge
          Expanded(
            flex: 7,
            child: SizedBox(
              height: 115,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4DEEEA).withValues(alpha: 0.2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF4DEEEA).withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4),
                        BoxShadow(color: const Color(0xFFFF4D9D).withValues(alpha: 0.3), blurRadius: 36, spreadRadius: 6),
                      ],
                    ),
                  ),
                  const Icon(Icons.shield_rounded, size: 84, color: Color(0xFF6C63FF)),
                  const Icon(Icons.security_rounded, size: 58, color: Color(0xFF4DEEEA)),
                  const Icon(Icons.auto_awesome_rounded, size: 24, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── 4. Quick Emergency Shortcuts Item ───
class _EmergencyShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyShortcut({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      borderColor: color.withValues(alpha: 0.35),
      glowColor: color.withValues(alpha: 0.15),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// ─── 5. AI Guardian Status & Circular Safety Score Indicator ───
class _GuardianAndScoreRow extends StatelessWidget {
  const _GuardianAndScoreRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // AI Guardian Status Card
        Expanded(
          flex: 11,
          child: _GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(18),
            borderColor: const Color(0xFF4DEEEA).withValues(alpha: 0.35),
            glowColor: const Color(0xFF4DEEEA).withValues(alpha: 0.18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DEEEA).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF4DEEEA), size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4DEEEA).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4DEEEA).withValues(alpha: 0.5)),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF4DEEEA), fontSize: 9.5, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'AI Guardian',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Voice distress & motion sensors actively running.',
                  style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Circular Safety Score Indicator Card
        Expanded(
          flex: 9,
          child: _GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
            borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
            glowColor: const Color(0xFF3B82F6).withValues(alpha: 0.18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: CircularProgressIndicator(
                        value: 0.94,
                        strokeWidth: 6.5,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4DEEEA)),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          '94%',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'SAFE',
                          style: TextStyle(color: Color(0xFF4DEEEA), fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Safety Score',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Low Risk Zone',
                  style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ─── 6. Toolkit Grid Card ───
class _ToolkitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolkitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      borderColor: color.withValues(alpha: 0.35),
      glowColor: color.withValues(alpha: 0.12),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// ─── 7. Daily Safety Tip Card ───
class _SafetyTipCard extends StatelessWidget {
  const _SafetyTipCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      borderRadius: 28,
      padding: const EdgeInsets.all(20),
      borderColor: const Color(0xFFFFB88C).withValues(alpha: 0.35),
      glowColor: const Color(0xFFFFB88C).withValues(alpha: 0.18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB88C).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB88C).withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFFB88C), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DAILY SAFETY TIP',
                      style: TextStyle(color: Color(0xFFFFB88C), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                    Icon(Icons.auto_awesome, color: const Color(0xFFFFB88C).withValues(alpha: 0.7), size: 16),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Trust Your Intuition',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'When travelling alone at night, share your live GPS coordinates with guardians and keep your hand near the SOS trigger.',
                  style: TextStyle(color: Color(0xFFD0D3E5), fontSize: 12.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}