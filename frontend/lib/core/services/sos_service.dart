import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/models/incident_model.dart';
import '../../shared/models/emergency_contact_model.dart';
import '../network/api_client.dart';
import '../network/websocket_client.dart';
import '../constants/api_constants.dart';
import 'location_service.dart';
import 'sms_fallback_service.dart';
import 'evidence_service.dart';

/// Central SOS orchestrator — coordinates the full emergency sequence.
///
/// When triggered (manually or by AI), it executes:
/// 1. Silent REST alert to backend (or SMS fallback if offline)
/// 2. Opens WebSocket for live location streaming
/// 3. Starts audio recording + camera capture
/// 4. Dispatches push notifications via FCM (backend-side)
/// 5. Switches location to high-accuracy mode
class SosService {
  final ApiClient _apiClient;
  final WebSocketClient _wsClient;
  final LocationService _locationService;
  final SmsFallbackService _smsFallback;
  final EvidenceService _evidenceService;

  SosState _state = SosState.idle;
  IncidentModel? _activeIncident;
  DateTime? _sosStartTime;
  Timer? _locationStreamTimer;

  final _stateController = StreamController<SosState>.broadcast();
  final _incidentController = StreamController<IncidentModel?>.broadcast();

  /// Stream of SOS state changes.
  Stream<SosState> get stateChanges => _stateController.stream;

  /// Stream of active incident updates.
  Stream<IncidentModel?> get incidentUpdates => _incidentController.stream;

  SosState get state => _state;
  IncidentModel? get activeIncident => _activeIncident;
  bool get isActive => _state == SosState.active;
  Duration? get elapsed => _sosStartTime != null
      ? DateTime.now().difference(_sosStartTime!)
      : null;

  SosService({
    required ApiClient apiClient,
    required WebSocketClient wsClient,
    required LocationService locationService,
    required SmsFallbackService smsFallback,
    required EvidenceService evidenceService,
  })  : _apiClient = apiClient,
        _wsClient = wsClient,
        _locationService = locationService,
        _smsFallback = smsFallback,
        _evidenceService = evidenceService;

  /// Trigger SOS — either manually or from the AI engine.
  ///
  /// [triggerType] indicates what triggered the SOS.
  /// [contacts] emergency contacts to notify.
  Future<bool> triggerSos({
    required TriggerType triggerType,
    required List<EmergencyContact> contacts,
    String? authToken,
  }) async {
    if (_state == SosState.active) {
      print('[SOS] Already active — ignoring duplicate trigger');
      return false;
    }

    _setState(SosState.triggering);
    _sosStartTime = DateTime.now();

    print('[SOS] 🆘 TRIGGERING SOS — Type: ${triggerType.value}');

    // Step 1: Get current location
    final location = _locationService.toGeoPoint() ??
        const GeoPoint(latitude: 0, longitude: 0);

    // Step 2: Send SOS alert to backend
    bool backendNotified = false;
    try {
      final response = await _apiClient.sosPost(
        ApiConstants.sosTrigger,
        data: {
          'triggerType': triggerType.value,
          'location': location.toGeoJson(),
          'timestamp': DateTime.now().toIso8601String(),
          'contactPhones': contacts
              .where((c) => c.notifyOnSos && c.phone.isNotEmpty)
              .map((c) => c.phone)
              .toList(),
          'contactEmails': contacts
              .where((c) => c.notifyOnSos && c.email.isNotEmpty)
              .map((c) => c.email)
              .toList(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _activeIncident = IncidentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        backendNotified = true;
        print('[SOS] Backend notified — Incident: ${_activeIncident!.id}');
      }
    } catch (e) {
      print('[SOS] Backend unreachable — falling back to SMS');
    }

    // Step 3: REAL-TIME Location Share & Automated Emergency Calling without arguments
    final smsSent = await _smsFallback.sendSosToContacts(contacts);
    print('[SOS] Real-time live location broadcasted to $smsSent emergency guardians!');

    try {
      final primaryPhone = contacts.isNotEmpty ? contacts.first.phone : '112';
      final callUri = Uri.parse('tel:$primaryPhone');
      await launchUrl(callUri, mode: LaunchMode.externalApplication);
      print('[SOS] Real-time emergency call placed automatically to $primaryPhone!');
    } catch (e) {
      print('[SOS] Could not trigger automatic calling: $e');
    }

    if (!backendNotified) {
      // Create local incident for tracking when offline
      _activeIncident = IncidentModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: '',
        triggerType: triggerType,
        timestamp: DateTime.now(),
        location: location,
        status: IncidentStatus.active,
      );
    }

    // Step 4: Switch to high-accuracy location tracking
    await _locationService.startHighAccuracyTracking();

    // Step 5: Open WebSocket for live tracking
    if (backendNotified && authToken != null && _activeIncident != null) {
      try {
        await _wsClient.connect(
          incidentId: _activeIncident!.id,
          authToken: authToken,
        );

        // Stream location updates via WebSocket
        _locationStreamTimer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => _streamLocation(),
        );
      } catch (e) {
        print('[SOS] WebSocket connection failed: $e');
      }
    }

    // Step 6: Start evidence collection
    await _evidenceService.startCollection();

    _setState(SosState.active);
    _incidentController.add(_activeIncident);

    print('[SOS] ✅ SOS ACTIVE — All protocols engaged');
    return true;
  }

  /// Resolve/cancel the active SOS.
  Future<void> resolveSos({String? notes}) async {
    if (_state != SosState.active) return;

    _setState(SosState.resolving);

    print('[SOS] Resolving SOS...');

    // Stop evidence collection
    await _evidenceService.stopCollection();

    // Stop WebSocket streaming
    _locationStreamTimer?.cancel();
    await _wsClient.disconnect();

    // Notify backend
    if (_activeIncident != null && !_activeIncident!.id.startsWith('local_')) {
      try {
        await _apiClient.put(
          ApiConstants.sosResolve(_activeIncident!.id),
          data: {
            'status': 'Resolved',
            'resolvedAt': DateTime.now().toIso8601String(),
            'notes': ?notes,
          },
        );
      } catch (e) {
        print('[SOS] Failed to notify backend of resolution: $e');
      }
    }

    // Revert to balanced-accuracy tracking
    await _locationService.stopTracking();
    await _locationService.startTracking();

    _activeIncident = null;
    _sosStartTime = null;
    _setState(SosState.idle);
    _incidentController.add(null);

    print('[SOS] ✅ SOS RESOLVED');
  }

  /// Stream current location via WebSocket.
  void _streamLocation() {
    final position = _locationService.lastPosition;
    if (position != null && _wsClient.isConnected) {
      _wsClient.sendLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed,
      );
    }
  }

  void _setState(SosState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  void dispose() {
    resolveSos();
    _stateController.close();
    _incidentController.close();
  }
}

/// State of the SOS service.
enum SosState {
  idle,       // No active SOS
  triggering, // SOS is being initiated
  active,     // SOS is active — evidence collection and tracking in progress
  resolving,  // SOS is being resolved
}
