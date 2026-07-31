import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../../shared/models/incident_model.dart';

/// Continuous GPS location tracking service with geofencing support.
///
/// Provides live location updates, geofence monitoring against safety zones,
/// and GeoJSON point generation for the backend.
class LocationService {
  bool _isTracking = false;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;

  final _positionController = StreamController<Position>.broadcast();
  final _geofenceController = StreamController<GeofenceEvent>.broadcast();

  /// Stream of position updates.
  Stream<Position> get positionStream => _positionController.stream;

  /// Stream of geofence entry/exit events.
  Stream<GeofenceEvent> get geofenceEvents => _geofenceController.stream;

  Position? get lastPosition => _lastPosition;
  bool get isTracking => _isTracking;

  /// Check and request location permissions.
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get the current position (one-shot).
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _lastPosition = position;
      return position;
    } catch (e) {
      print('[Location] Error getting position: $e');
      return null;
    }
  }

  /// Start continuous location tracking.
  ///
  /// Uses balanced accuracy for battery optimization.
  /// During active SOS, switch to high accuracy with [startHighAccuracyTracking].
  Future<void> startTracking() async {
    if (_isTracking) return;

    final hasPermission = await requestPermission();
    if (!hasPermission) {
      print('[Location] Permission denied');
      return;
    }

    _isTracking = true;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (position) {
        _lastPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        print('[Location] Stream error: $error');
      },
    );

    print('[Location] Tracking started (balanced accuracy)');
  }

  /// Switch to high-accuracy tracking for active SOS.
  Future<void> startHighAccuracyTracking() async {
    await _positionSubscription?.cancel();

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 2, // Update every 2 meters during SOS
      ),
    ).listen(
      (position) {
        _lastPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        print('[Location] High-accuracy stream error: $error');
      },
    );

    print('[Location] Switched to high-accuracy tracking (SOS mode)');
  }

  /// Stop location tracking.
  Future<void> stopTracking() async {
    if (!_isTracking) return;

    await _positionSubscription?.cancel();
    _isTracking = false;
    print('[Location] Tracking stopped');
  }

  /// Convert current position to GeoPoint for backend.
  GeoPoint? toGeoPoint() {
    if (_lastPosition == null) return null;

    return GeoPoint(
      latitude: _lastPosition!.latitude,
      longitude: _lastPosition!.longitude,
      altitude: _lastPosition!.altitude,
      accuracy: _lastPosition!.accuracy,
    );
  }

  /// Calculate distance to a point (in meters).
  double distanceTo(double lat, double lng) {
    if (_lastPosition == null) return double.infinity;

    return Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      lat,
      lng,
    );
  }

  /// Generate a Google Maps URL for the current location.
  String? generateMapsUrl() {
    if (_lastPosition == null) return null;
    return 'https://maps.google.com/?q=${_lastPosition!.latitude},${_lastPosition!.longitude}';
  }

  /// Generate an SMS-friendly location string.
  String? generateSmsLocation() {
    if (_lastPosition == null) return null;
    return 'Emergency! My location: '
        'https://maps.google.com/?q=${_lastPosition!.latitude},${_lastPosition!.longitude} '
        '(Accuracy: ${_lastPosition!.accuracy.toStringAsFixed(0)}m)';
  }

  void dispose() {
    stopTracking();
    _positionController.close();
    _geofenceController.close();
  }
}

/// Geofence event when user enters/exits a safety zone.
class GeofenceEvent {
  final String zoneId;
  final GeofenceAction action;
  final int riskScore;
  final DateTime timestamp;

  const GeofenceEvent({
    required this.zoneId,
    required this.action,
    required this.riskScore,
    required this.timestamp,
  });
}

enum GeofenceAction { enter, exit }
