import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../../shared/models/incident_model.dart';
import 'dart:async';
import 'dart:math';
/// Location state management.
class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;

  StreamSubscription<Position>? _positionSubscription;

  Position? _currentPosition;
  bool _isTracking = false;
  bool _hasPermission = false;
  String? _error;
  double _safetyScore = 0.94;
  Timer? _safetyScoreTimer;

  LocationProvider({required LocationService locationService})
      : _locationService = locationService;

  Position? get currentPosition => _currentPosition;
  bool get isTracking => _isTracking;
  bool get hasPermission => _hasPermission;
  String? get error => _error;
  double get safetyScore => _safetyScore;
  GeoPoint? get currentGeoPoint => _locationService.toGeoPoint();

  /// Initialize location tracking.
  Future<void> initialize() async {
    _hasPermission = await _locationService.requestPermission();
    if (!_hasPermission) {
      _error = 'Location permission denied';
      notifyListeners();
      return;
    }

    // Get initial position
    _currentPosition = await _locationService.getCurrentPosition();
    notifyListeners();

    // Start continuous tracking
    await startTracking();
  }

  /// Fetch and update immediate current GPS position.
  Future<Position?> getCurrentPosition() async {
    _currentPosition = await _locationService.getCurrentPosition();
    notifyListeners();
    return _currentPosition;
  }

  /// Start tracking.
  Future<void> startTracking() async {
    if (_isTracking) return;

    await _locationService.startTracking();
    _isTracking = true;

    _positionSubscription = _locationService.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _safetyScoreTimer?.cancel();
    _safetyScoreTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Simulate real-time safety score fluctuations between 88% and 98%
      final random = Random();
      final change = (random.nextDouble() * 0.04) - 0.02; // -2% to +2%
      _safetyScore = (_safetyScore + change).clamp(0.85, 0.98);
      notifyListeners();
    });

    notifyListeners();
  }

  /// Stop tracking.
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _safetyScoreTimer?.cancel();
    await _locationService.stopTracking();
    _isTracking = false;
    notifyListeners();
  }

  /// Get Google Maps URL for current location.
  String? get mapsUrl => _locationService.generateMapsUrl();

  /// Distance to a point in meters.
  double distanceTo(double lat, double lng) {
    return _locationService.distanceTo(lat, lng);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _safetyScoreTimer?.cancel();
    super.dispose();
  }
}
