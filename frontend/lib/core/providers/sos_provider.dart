import 'package:flutter/material.dart';
import '../services/sos_service.dart';
import '../services/ai_engine.dart';
import '../services/fake_call_service.dart';
import '../storage/storage_service.dart';
import '../../shared/models/incident_model.dart';
import '../../shared/models/emergency_contact_model.dart';
import 'dart:async';

/// SOS state management — coordinates AI engine, SOS service,
/// and fake call service into a unified state.
class SosProvider extends ChangeNotifier {
  final SosService _sosService;
  final AiEngine _aiEngine;
  final FakeCallService _fakeCallService;
  final StorageService _storage;

  StreamSubscription? _threatSubscription;
  StreamSubscription? _actionSubscription;
  StreamSubscription? _sosStateSubscription;
  StreamSubscription? _callSubscription;

  // State
  ThreatLevel _threatLevel = ThreatLevel.safe;
  ThreatAssessment? _lastAssessment;
  SosState _sosState = SosState.idle;
  IncidentModel? _activeIncident;
  bool _aiMonitoringActive = false;
  FakeCallEvent? _currentCallEvent;

  // Emergency contacts (loaded from user profile)
  List<EmergencyContact> _emergencyContacts = [];

  SosProvider({
    required SosService sosService,
    required AiEngine aiEngine,
    required FakeCallService fakeCallService,
    required StorageService storage,
  })  : _sosService = sosService,
        _aiEngine = aiEngine,
        _fakeCallService = fakeCallService,
        _storage = storage {
    _setupListeners();
  }

  // ─── Getters ─────────────────────────────────────────────

  ThreatLevel get threatLevel => _threatLevel;
  ThreatAssessment? get lastAssessment => _lastAssessment;
  SosState get sosState => _sosState;
  IncidentModel? get activeIncident => _activeIncident;
  bool get isAiMonitoring => _aiMonitoringActive;
  bool get isSosActive => _sosState == SosState.active;
  FakeCallEvent? get currentCallEvent => _currentCallEvent;
  Duration? get sosElapsed => _sosService.elapsed;

  // ─── AI Monitoring Control ───────────────────────────────

  /// Start AI monitoring (voice + motion).
  void startAiMonitoring() {
    _aiEngine.start();
    _aiMonitoringActive = true;
    notifyListeners();
    print('[SosProvider] AI monitoring started');
  }

  /// Stop AI monitoring.
  void stopAiMonitoring() {
    _aiEngine.stop();
    _aiMonitoringActive = false;
    _threatLevel = ThreatLevel.safe;
    notifyListeners();
    print('[SosProvider] AI monitoring stopped');
  }

  // ─── SOS Control ─────────────────────────────────────────

  /// Manually trigger SOS.
  Future<bool> triggerManualSos() async {
    final token = await _storage.getAuthToken();
    return _sosService.triggerSos(
      triggerType: TriggerType.manual,
      contacts: _emergencyContacts,
      authToken: token,
    );
  }

  /// Resolve active SOS.
  Future<void> resolveSos({String? notes}) async {
    await _sosService.resolveSos(notes: notes);
    _aiEngine.resetThreatLevel();
  }

  // ─── Fake Call Control ───────────────────────────────────

  /// Trigger a fake incoming call.
  void triggerFakeCall({
    String callerName = 'Mom',
    String callerNumber = '+91 98765 43210',
    Duration delay = Duration.zero,
  }) {
    _fakeCallService.triggerFakeCall(
      callerName: callerName,
      callerNumber: callerNumber,
      delay: delay,
    );
  }

  void answerFakeCall() => _fakeCallService.answerCall();
  void endFakeCall() => _fakeCallService.endCall();

  // ─── Emergency Contacts ──────────────────────────────────

  void setEmergencyContacts(List<EmergencyContact> contacts) {
    _emergencyContacts = contacts;
    notifyListeners();
  }

  // ─── Internal Listeners ──────────────────────────────────

  void _setupListeners() {
    // Listen to threat assessments
    _threatSubscription = _aiEngine.threatAssessments.listen((assessment) {
      _threatLevel = assessment.level;
      _lastAssessment = assessment;
      notifyListeners();
    });

    // Listen to recommended actions
    _actionSubscription = _aiEngine.recommendedActions.listen((action) async {
      switch (action) {
        case ThreatAction.autoSos:
          // Auto-trigger SOS
          final token = await _storage.getAuthToken();
          final triggerType = _lastAssessment?.isMultiModal == true
              ? TriggerType.multiModal
              : (_lastAssessment?.voiceEvent != null
                  ? TriggerType.voice
                  : TriggerType.motion);

          await _sosService.triggerSos(
            triggerType: triggerType,
            contacts: _emergencyContacts,
            authToken: token,
          );
          break;

        case ThreatAction.fakeCall:
          _fakeCallService.triggerFakeCall();
          break;

        case ThreatAction.userAlert:
          // Handled via UI — the threat level change triggers a visual alert
          break;

        case ThreatAction.none:
          break;
      }
    });

    // Listen to SOS state changes
    _sosStateSubscription = _sosService.stateChanges.listen((state) {
      _sosState = state;
      notifyListeners();
    });

    // Listen to active incident
    _sosService.incidentUpdates.listen((incident) {
      _activeIncident = incident;
      notifyListeners();
    });

    // Listen to fake call events
    _callSubscription = _fakeCallService.callEvents.listen((event) {
      _currentCallEvent = event;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _threatSubscription?.cancel();
    _actionSubscription?.cancel();
    _sosStateSubscription?.cancel();
    _callSubscription?.cancel();
    super.dispose();
  }
}
