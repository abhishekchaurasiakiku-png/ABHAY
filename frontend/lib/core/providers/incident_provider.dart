import 'package:flutter/material.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../../shared/models/incident_model.dart';

/// Incident history state management.
class IncidentProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  List<IncidentModel> _incidents = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  IncidentProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  List<IncidentModel> get incidents => _incidents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  /// Fetch incident history (paginated).
  Future<void> fetchIncidents({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.get(
        ApiConstants.incidents,
        queryParameters: {
          'page': _currentPage,
          'limit': 20,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final incidentList = (data['incidents'] as List<dynamic>?)
              ?.map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      if (refresh) {
        _incidents = incidentList;
      } else {
        _incidents.addAll(incidentList);
      }

      _hasMore = incidentList.length >= 20;
      _currentPage++;
    } catch (e) {
      _error = 'Failed to load incidents';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get incident details by ID.
  Future<IncidentModel?> getIncidentDetail(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.incidentDetail(id));
      return IncidentModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _error = 'Failed to load incident details';
      notifyListeners();
      return null;
    }
  }

  /// Filter incidents by trigger type.
  List<IncidentModel> filterByType(TriggerType type) {
    return _incidents.where((i) => i.triggerType == type).toList();
  }

  /// Get count of active incidents.
  int get activeCount => _incidents.where((i) => i.isActive).length;
}
