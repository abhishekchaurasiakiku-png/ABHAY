import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/models/incident_model.dart';
import '../../shared/widgets/incident_card.dart';

/// Incident history timeline with trigger type filtering.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TriggerType? _selectedFilter;

  // Demo incidents for development UI
  final List<IncidentModel> _demoIncidents = [
    IncidentModel(
      id: '1',
      userId: 'u1',
      triggerType: TriggerType.voice,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      location: const GeoPoint(latitude: 28.6139, longitude: 77.2090),
      status: IncidentStatus.resolved,
      mediaLinks: ['audio1.m4a'],
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
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      location: const GeoPoint(latitude: 28.5355, longitude: 77.3910),
      status: IncidentStatus.resolved,
      mediaLinks: ['audio2.m4a', 'photo1.jpg', 'photo2.jpg'],
    ),
    IncidentModel(
      id: '4',
      userId: 'u1',
      triggerType: TriggerType.multiModal,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      location: const GeoPoint(latitude: 28.7041, longitude: 77.1025),
      status: IncidentStatus.resolved,
      mediaLinks: ['audio3.m4a', 'photo3.jpg'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter != null
        ? _demoIncidents.where((i) => i.triggerType == _selectedFilter).toList()
        : _demoIncidents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Incident History'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == null,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                _FilterChip(
                  label: '🎙️ Voice',
                  isSelected: _selectedFilter == TriggerType.voice,
                  onTap: () => setState(() => _selectedFilter = TriggerType.voice),
                ),
                _FilterChip(
                  label: '📳 Motion',
                  isSelected: _selectedFilter == TriggerType.motion,
                  onTap: () => setState(() => _selectedFilter = TriggerType.motion),
                ),
                _FilterChip(
                  label: '🆘 Manual',
                  isSelected: _selectedFilter == TriggerType.manual,
                  onTap: () => setState(() => _selectedFilter = TriggerType.manual),
                ),
                _FilterChip(
                  label: '🤖 AI',
                  isSelected: _selectedFilter == TriggerType.multiModal,
                  onTap: () => setState(() => _selectedFilter = TriggerType.multiModal),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Incidents list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 60,
                          color: AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No incidents recorded',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return IncidentCard(
                        incident: filtered[index],
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}