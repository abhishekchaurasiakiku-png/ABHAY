import 'dart:ui';
import 'package:flutter/material.dart';

/// Privacy & Safety Data Security Policy Screen with Glassmorphism UI.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D19),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4DEEEA)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy & Data Security',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const _AuroraBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Shield Badge
                  _GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(22),
                    borderColor: const Color(0xFF00E676).withValues(alpha: 0.4),
                    glowColor: const Color(0xFF00E676).withValues(alpha: 0.15),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF00E676), width: 1.5),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Color(0xFF00E676), size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Your Safety, Your Control',
                                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'We safeguard your digital freedom with on-device AI algorithms and rigorous encryption protocols.',
                                style: TextStyle(color: Color(0xFFD0D3E5), fontSize: 13, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'How SafeHer-AI Protects Your Data 🔒',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),

                  _buildPolicySection(
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF4DEEEA),
                    title: '1. On-Device Voice AI Processing',
                    description:
                        'Our Voice Distress AI ("Help me" & "Bachao" acoustic recognition) executes locally on your device CPU. Continuous audio streams are processed solely in temporary memory and are NEVER recorded, saved, or transmitted to cloud servers unless an active SOS alert is explicitly validated.',
                  ),
                  const SizedBox(height: 16),

                  _buildPolicySection(
                    icon: Icons.location_on_rounded,
                    color: const Color(0xFFFF4D9D),
                    title: '2. Real-Time Location & Geofence Privacy',
                    description:
                        'Your high-accuracy GPS coordinates and safe route calculations remain completely private. Your real-time tracking link is ONLY transmitted directly to your selected Trusted Emergency Guardians when an SOS alert is activated.',
                  ),
                  const SizedBox(height: 16),

                  _buildPolicySection(
                    icon: Icons.security_rounded,
                    color: const Color(0xFF6C63FF),
                    title: '3. AES-256 End-to-End Storage Encryption',
                    description:
                        'User identity profiles, guardian telephone records, and incident evidence logs are stored locally using banking-grade AES-256 encrypted Flutter Secure Storage before syncing across SSL-protected MongoDB endpoints.',
                  ),
                  const SizedBox(height: 16),

                  _buildPolicySection(
                    icon: Icons.block_rounded,
                    color: const Color(0xFFFFB88C),
                    title: '4. Zero Commercial Data Monetization',
                    description:
                        'SafeHer-AI operates on a strict zero-ad and zero-data selling architecture. Your safety analytics and guardian profile will never be shared with advertisers or third-party tracking networks.',
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      '© 2026 SafeHer-AI Guardian Trust Shield\nCommitted to advancing women’s physical and data safety worldwide.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return _GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(18),
      borderColor: color.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(description, style: const TextStyle(color: Color(0xFFB0B3C7), fontSize: 13, height: 1.45)),
              ],
            ),
          ),
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
          top: -40,
          right: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF00E676).withValues(alpha: 0.25), const Color(0xFF00E676).withValues(alpha: 0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [const Color(0xFF6C63FF).withValues(alpha: 0.25), const Color(0xFF6C63FF).withValues(alpha: 0.0)],
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
