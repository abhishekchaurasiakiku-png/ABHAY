import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Safe route screen for predictive safety routing.
///
/// Users input a destination and the app suggests the safest route
/// (not just the fastest) based on safety scores.
class SafeRouteScreen extends StatelessWidget {
  const SafeRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Safe Route'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                children: [
                  // From
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.safe.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.my_location, color: AppColors.safe, size: 18),
                    ),
                    title: const Text(
                      'Current Location',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    ),
                    subtitle: const Text(
                      'Using GPS',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 11),
                    ),
                  ),

                  const Divider(color: AppColors.surfaceBorder, height: 1),

                  // To
                  ListTile(
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.emergency.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.emergency, size: 18),
                    ),
                    title: const TextField(
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Enter destination',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Route options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _RouteOption(
                  label: 'Safest Route',
                  safetyScore: 9.2,
                  distance: '3.4 km',
                  duration: '12 min',
                  highlights: ['Well-lit streets', 'CCTV coverage', 'High foot traffic'],
                  isRecommended: true,
                ),
                const SizedBox(height: 10),
                _RouteOption(
                  label: 'Balanced Route',
                  safetyScore: 7.1,
                  distance: '2.8 km',
                  duration: '9 min',
                  highlights: ['Partially lit', 'Some isolated stretches'],
                ),
                const SizedBox(height: 10),
                _RouteOption(
                  label: 'Fastest Route',
                  safetyScore: 4.5,
                  distance: '2.1 km',
                  duration: '7 min',
                  highlights: ['Poorly lit areas', 'Low foot traffic', 'Recent incidents'],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteOption extends StatelessWidget {
  final String label;
  final double safetyScore;
  final String distance;
  final String duration;
  final List<String> highlights;
  final bool isRecommended;

  const _RouteOption({
    required this.label,
    required this.safetyScore,
    required this.distance,
    required this.duration,
    required this.highlights,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = safetyScore >= 8
        ? AppColors.safe
        : safetyScore >= 6
            ? AppColors.warning
            : AppColors.danger;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRecommended
              ? AppColors.safe.withValues(alpha: 0.5)
              : AppColors.surfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isRecommended) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.safe.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✓ Recommended',
                    style: TextStyle(
                      color: AppColors.safe,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Safety score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${safetyScore.toStringAsFixed(1)}/10',
                  style: TextStyle(
                    color: scoreColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.straighten, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(distance, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(duration, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: highlights.map((h) {
              final isPositive = h.contains('Well-lit') || h.contains('CCTV') || h.contains('High');
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.safe : AppColors.warning).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  h,
                  style: TextStyle(
                    color: isPositive ? AppColors.safe : AppColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
