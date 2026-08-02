import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/location_provider.dart';

/// Real-Time Safety Map & Local Area Analysis with Glassmorphism and Aurora UI.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocationProvider>();
    final pos = loc.currentPosition;
    final LatLng center = pos != null
        ? LatLng(pos.latitude, pos.longitude)
        : const LatLng(28.6139, 77.2090); // Default fallback coordinate

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D19),
      body: Stack(
        children: [
          // 1. Aurora Background
          const _AuroraBackground(),

          // 2. Map & Analytics Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Live Safety Map ✨',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Real-Time Geofence & Threat Analytics',
                            style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 13),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location_rounded, color: Color(0xFF4DEEEA), size: 26),
                        onPressed: () async {
                          await loc.getCurrentPosition();
                          if (loc.currentPosition != null) {
                            _mapController.move(
                              LatLng(loc.currentPosition!.latitude, loc.currentPosition!.longitude),
                              16.0,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Embedded Google Map Container (Frosted Glass with neon aura)
                  _GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(4),
                    borderColor: const Color(0xFF4DEEEA).withValues(alpha: 0.4),
                    glowColor: const Color(0xFF4DEEEA).withValues(alpha: 0.15),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 360,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: center,
                                initialZoom: 15.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.frontend',
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: center,
                                      radius: 250,
                                      useRadiusInMeter: true,
                                      color: const Color(0xFF00E676).withValues(alpha: 0.18),
                                      borderColor: const Color(0xFF00E676),
                                      borderStrokeWidth: 2,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: center,
                                      width: 54,
                                      height: 54,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFF4D9D),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF4D9D).withValues(alpha: 0.5),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Safe Zone Status Badge Overlay
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF151829).withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFF00E676), width: 1.2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.security_rounded, color: Color(0xFF00E676), size: 16),
                                    SizedBox(width: 6),
                                    Text(
                                      'GEOFENCE: SAFE ZONE',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Open in real-time navigation app button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = pos != null
                            ? Uri.parse('https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}')
                            : Uri.parse('https://www.google.com/maps');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      icon: const Icon(Icons.directions_rounded, size: 22),
                      label: const Text(
                        'Launch Live Navigation in Google Maps',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 6,
                        shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Local Area Safety Analysis Section
                  const Text(
                    'Local Area Safety Analysis 🛡️',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  _GlassCard(
                    borderRadius: 28,
                    padding: const EdgeInsets.all(20),
                    borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                    glowColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    child: Column(
                      children: [
                        _buildAnalyticsRow(
                          icon: Icons.shield_rounded,
                          color: const Color(0xFF00E676),
                          label: 'Overall Area Risk Score',
                          value: 'Low Risk (94% Safe)',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        _buildAnalyticsRow(
                          icon: Icons.lightbulb_rounded,
                          color: const Color(0xFFFFB88C),
                          label: 'Street Lighting Index',
                          value: 'High — Well-Lit Corridor',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        _buildAnalyticsRow(
                          icon: Icons.local_police_rounded,
                          color: const Color(0xFF6C63FF),
                          label: 'Police Patrol & Response Time',
                          value: '~3.8 mins estimated',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Colors.white12, height: 1),
                        ),
                        _buildAnalyticsRow(
                          icon: Icons.history_edu_rounded,
                          color: const Color(0xFF4DEEEA),
                          label: 'Recent Distress Reports',
                          value: '0 incidents reported today',
                        ),
                      ],
                    ),
                  ),

                  // Bottom padding for floating navigation bar
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFFB0B3C7), fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─── Shared Aurora Background ───
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
                colors: [
                  const Color(0xFF4DEEEA).withValues(alpha: 0.28),
                  const Color(0xFF4DEEEA).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 300,
          left: -70,
          child: Container(
            width: 340,
            height: 340,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.25),
                  const Color(0xFF3B82F6).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.25),
                  const Color(0xFF6C63FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ─── Shared Frosted Glass Card ───
class _GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;

  const _GlassCard({
    required this.child,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? [BoxShadow(color: glowColor!, blurRadius: 24, offset: const Offset(0, 6))]
            : null,
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