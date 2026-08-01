import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/incident_model.dart';
import '../../shared/widgets/incident_card.dart';

/// Support Helplines & AI Incident History with Glassmorphism & Aurora UI.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TriggerType? _selectedFilter;

  final List<IncidentModel> _demoIncidents = [
    IncidentModel(
      id: '1',
      userId: 'u1',
      triggerType: TriggerType.voice,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      location: const GeoPoint(latitude: 28.6139, longitude: 77.2090),
      status: IncidentStatus.resolved,
      mediaLinks: ['audio_evidence_1.m4a'],
    ),
    IncidentModel(
      id: '2',
      userId: 'u1',
      triggerType: TriggerType.motion,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      location: const GeoPoint(latitude: 28.6448, longitude: 77.2167),
      status: IncidentStatus.falseAlarm,
    ),
    IncidentModel(
      id: '3',
      userId: 'u1',
      triggerType: TriggerType.manual,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      location: const GeoPoint(latitude: 28.5355, longitude: 77.3910),
      status: IncidentStatus.resolved,
      mediaLinks: ['audio2.m4a', 'photo1.jpg'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter != null
        ? _demoIncidents.where((i) => i.triggerType == _selectedFilter).toList()
        : _demoIncidents;

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
                    'Support & Helplines ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Immediate National Helplines & AI Security Logs',
                    style: TextStyle(color: Color(0xFFB0B3C7), fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // National Emergency Helplines Grid
                  const Text(
                    '24/7 Rapid Response Helplines 📞',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _HelplineCard(
                        title: 'Women Helpline',
                        number: '1091',
                        subtitle: 'National Support',
                        color: const Color(0xFFFF4D9D),
                        onTap: () => _dialNumber('1091', context),
                      ),
                      _HelplineCard(
                        title: 'Abuse Helpline',
                        number: '181',
                        subtitle: 'Domestic Support',
                        color: const Color(0xFF6C63FF),
                        onTap: () => _dialNumber('181', context),
                      ),
                      _HelplineCard(
                        title: 'Police Force',
                        number: '112',
                        subtitle: 'Immediate Emergency',
                        color: const Color(0xFF4DEEEA),
                        onTap: () => _dialNumber('112', context),
                      ),
                      _HelplineCard(
                        title: 'Ambulance & Med',
                        number: '108',
                        subtitle: 'Medical Response',
                        color: const Color(0xFFFFB88C),
                        onTap: () => _dialNumber('108', context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // AI Security Incident Logs
                  const Text(
                    'AI Protection Activity Logs 📋',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),

                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _selectedFilter == null,
                          onTap: () => setState(() => _selectedFilter = null),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '🎙️ Voice',
                          isSelected: _selectedFilter == TriggerType.voice,
                          onTap: () => setState(() => _selectedFilter = TriggerType.voice),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '📳 Motion',
                          isSelected: _selectedFilter == TriggerType.motion,
                          onTap: () => setState(() => _selectedFilter = TriggerType.motion),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '🆘 Manual',
                          isSelected: _selectedFilter == TriggerType.manual,
                          onTap: () => setState(() => _selectedFilter = TriggerType.manual),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: '🤖 AI',
                          isSelected: _selectedFilter == TriggerType.multiModal,
                          onTap: () => setState(() => _selectedFilter = TriggerType.multiModal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Incident Cards inside Frosted Wrappers
                  if (filtered.isEmpty)
                    _GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(30),
                      child: Center(
                        child: Text(
                          'No security incidents found in this filter category.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _GlassCard(
                          borderRadius: 22,
                          padding: EdgeInsets.zero,
                          borderColor: Colors.white.withValues(alpha: 0.12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: IncidentCard(
                              incident: filtered[index],
                              onTap: () {},
                            ),
                          ),
                        );
                      },
                    ),

                  // Bottom padding for floating navigation
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialNumber(String number, BuildContext context) async {
    final uri = Uri.parse('tel:$number');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not initiate dialer to $number')),
        );
      }
    }
  }
}

class _HelplineCard extends StatelessWidget {
  final String title;
  final String number;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HelplineCard({
    required this.title,
    required this.number,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D32).withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          number,
                          style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: Icon(Icons.call_rounded, color: color, size: 16),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFFB0B3C7), fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4DEEEA).withValues(alpha: 0.25) : const Color(0xFF1A1D32).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4DEEEA) : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF4DEEEA) : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
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
          left: -40,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  const Color(0xFF6C63FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 250,
          right: -60,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF4D9D).withValues(alpha: 0.25),
                  const Color(0xFFFF4D9D).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: -50,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF4DEEEA).withValues(alpha: 0.2),
                  const Color(0xFF4DEEEA).withValues(alpha: 0.0),
                ],
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

  const _GlassCard({
    required this.child,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius)),
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