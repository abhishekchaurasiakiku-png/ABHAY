import 'dart:async';
import 'voice_distress_service.dart';
import 'motion_analysis_service.dart';

/// Multi-modal AI fusion engine.
///
/// Orchestrates voice distress and motion analysis services,
/// combining their outputs to produce a unified threat-level
/// assessment. This multi-modal fusion significantly reduces
/// false positives compared to single-signal detection.
///
/// Threat Level Decision Matrix:
/// ┌───────────────────┬──────────────┬────────────────┬───────────────────┐
/// │                   │ No Motion    │ Low Motion     │ High Motion       │
/// ├───────────────────┼──────────────┼────────────────┼───────────────────┤
/// │ No Voice          │ SAFE         │ LOW            │ MEDIUM            │
/// │ Low Voice         │ LOW          │ MEDIUM         │ HIGH              │
/// │ High Voice        │ MEDIUM       │ HIGH           │ CRITICAL          │
/// └───────────────────┴──────────────┴────────────────┴───────────────────┘
class AiEngine {
  final VoiceDistressService _voiceService;
  final MotionAnalysisService _motionService;

  StreamSubscription? _voiceSubscription;
  StreamSubscription? _motionSubscription;
  Timer? _decayTimer;

  // Current state
  ThreatLevel _currentThreatLevel = ThreatLevel.safe;
  VoiceDistressEvent? _lastVoiceEvent;
  MotionAnomalyEvent? _lastMotionEvent;

  // Time windows for signal fusion
  static const Duration _fusionWindow = Duration(seconds: 10);
  static const Duration _decayInterval = Duration(seconds: 5);

  final _threatController = StreamController<ThreatAssessment>.broadcast();
  final _actionController = StreamController<ThreatAction>.broadcast();

  /// Stream of threat level assessments.
  Stream<ThreatAssessment> get threatAssessments => _threatController.stream;

  /// Stream of recommended actions.
  Stream<ThreatAction> get recommendedActions => _actionController.stream;

  ThreatLevel get currentThreatLevel => _currentThreatLevel;

  AiEngine({
    required VoiceDistressService voiceService,
    required MotionAnalysisService motionService,
  })  : _voiceService = voiceService,
        _motionService = motionService;

  /// Start the AI engine — begins listening to voice and motion streams.
  void start() {
    _voiceSubscription = _voiceService.distressEvents.listen(_onVoiceDistress);
    _motionSubscription = _motionService.anomalyEvents.listen(_onMotionAnomaly);

    // Decay timer: reduce threat level if no new signals
    _decayTimer = Timer.periodic(_decayInterval, (_) => _decayThreatLevel());

    print('[AIEngine] Started — multi-modal fusion active');
  }

  /// Stop the AI engine.
  void stop() {
    _voiceSubscription?.cancel();
    _motionSubscription?.cancel();
    _decayTimer?.cancel();
    _currentThreatLevel = ThreatLevel.safe;

    print('[AIEngine] Stopped');
  }

  void _onVoiceDistress(VoiceDistressEvent event) {
    _lastVoiceEvent = event;
    _evaluateThreat();
  }

  void _onMotionAnomaly(MotionAnomalyEvent event) {
    _lastMotionEvent = event;
    _evaluateThreat();
  }

  /// Core fusion logic: combine voice and motion signals
  /// to determine threat level and recommended action.
  void _evaluateThreat() {
    final now = DateTime.now();

    // Check if signals are within the fusion time window
    final voiceActive = _lastVoiceEvent != null &&
        now.difference(_lastVoiceEvent!.timestamp) < _fusionWindow;
    final motionActive = _lastMotionEvent != null &&
        now.difference(_lastMotionEvent!.timestamp) < _fusionWindow;

    final voiceConfidence = voiceActive ? _lastVoiceEvent!.confidence : 0.0;
    final motionConfidence = motionActive ? _lastMotionEvent!.confidence : 0.0;

    // Determine voice signal strength
    final voiceLevel = _categorizeSignal(voiceConfidence);
    final motionLevel = _categorizeSignal(motionConfidence);

    // Apply fusion matrix
    ThreatLevel newLevel;
    if (voiceLevel == _SignalLevel.high && motionLevel == _SignalLevel.high) {
      newLevel = ThreatLevel.critical;
    } else if (voiceLevel == _SignalLevel.high && motionLevel == _SignalLevel.low ||
               voiceLevel == _SignalLevel.low && motionLevel == _SignalLevel.high) {
      newLevel = ThreatLevel.high;
    } else if (voiceLevel == _SignalLevel.high && motionLevel == _SignalLevel.none ||
               voiceLevel == _SignalLevel.none && motionLevel == _SignalLevel.high) {
      newLevel = ThreatLevel.medium;
    } else if (voiceLevel == _SignalLevel.low && motionLevel == _SignalLevel.low) {
      newLevel = ThreatLevel.medium;
    } else if (voiceLevel == _SignalLevel.low || motionLevel == _SignalLevel.low) {
      newLevel = ThreatLevel.low;
    } else {
      newLevel = ThreatLevel.safe;
    }

    // Special case: high-confidence fall always escalates to HIGH
    if (motionActive &&
        _lastMotionEvent!.type == MotionAnomalyType.fall &&
        _lastMotionEvent!.confidence > 0.85) {
      newLevel = ThreatLevel.high;
    }

    // Only emit if threat level changed or escalated
    if (newLevel.index >= _currentThreatLevel.index) {
      _currentThreatLevel = newLevel;

      final assessment = ThreatAssessment(
        level: newLevel,
        voiceEvent: voiceActive ? _lastVoiceEvent : null,
        motionEvent: motionActive ? _lastMotionEvent : null,
        combinedConfidence: _calculateCombinedConfidence(voiceConfidence, motionConfidence),
        timestamp: now,
      );

      _threatController.add(assessment);
      _emitAction(assessment);
    }
  }

  _SignalLevel _categorizeSignal(double confidence) {
    if (confidence >= 0.75) return _SignalLevel.high;
    if (confidence >= 0.40) return _SignalLevel.low;
    return _SignalLevel.none;
  }

  double _calculateCombinedConfidence(double voice, double motion) {
    if (voice > 0 && motion > 0) {
      // Multi-modal boost: combined signals are more reliable
      return (voice * 0.5 + motion * 0.5 + 0.15).clamp(0.0, 1.0);
    }
    return (voice + motion).clamp(0.0, 1.0);
  }

  /// Emit the recommended action based on threat level.
  void _emitAction(ThreatAssessment assessment) {
    ThreatAction action;

    switch (assessment.level) {
      case ThreatLevel.critical:
        action = ThreatAction.autoSos;
        break;
      case ThreatLevel.high:
        action = ThreatAction.autoSos;
        break;
      case ThreatLevel.medium:
        action = ThreatAction.fakeCall;
        break;
      case ThreatLevel.low:
        action = ThreatAction.userAlert;
        break;
      case ThreatLevel.safe:
        action = ThreatAction.none;
        break;
    }

    _actionController.add(action);
    print('[AIEngine] Threat: ${assessment.level.name} → Action: ${action.name}');
  }

  /// Gradually reduce threat level if no new signals arrive.
  void _decayThreatLevel() {
    if (_currentThreatLevel == ThreatLevel.safe) return;

    final now = DateTime.now();
    final voiceStale = _lastVoiceEvent == null ||
        now.difference(_lastVoiceEvent!.timestamp) > _fusionWindow;
    final motionStale = _lastMotionEvent == null ||
        now.difference(_lastMotionEvent!.timestamp) > _fusionWindow;

    if (voiceStale && motionStale) {
      // Step down one level
      final newIndex = (_currentThreatLevel.index - 1).clamp(0, ThreatLevel.values.length - 1);
      _currentThreatLevel = ThreatLevel.values[newIndex];

      _threatController.add(ThreatAssessment(
        level: _currentThreatLevel,
        timestamp: now,
        combinedConfidence: 0.0,
      ));
    }
  }

  /// Manually reset threat level (e.g., after resolving an incident).
  void resetThreatLevel() {
    _currentThreatLevel = ThreatLevel.safe;
    _lastVoiceEvent = null;
    _lastMotionEvent = null;
    _threatController.add(ThreatAssessment(
      level: ThreatLevel.safe,
      timestamp: DateTime.now(),
      combinedConfidence: 0.0,
    ));
  }

  void dispose() {
    stop();
    _threatController.close();
    _actionController.close();
  }
}

/// Threat levels from the AI fusion engine.
enum ThreatLevel {
  safe,      // No concerning signals
  low,       // Minor signal, monitor
  medium,    // Moderate concern, offer fake call
  high,      // High confidence distress, auto-SOS
  critical,  // Multi-modal confirmed emergency, immediate SOS
}

/// Recommended actions based on threat level.
enum ThreatAction {
  none,       // No action needed
  userAlert,  // Show a subtle alert to user
  fakeCall,   // Trigger fake incoming call
  autoSos,    // Automatically trigger SOS protocol
}

/// Combined threat assessment from the fusion engine.
class ThreatAssessment {
  final ThreatLevel level;
  final VoiceDistressEvent? voiceEvent;
  final MotionAnomalyEvent? motionEvent;
  final double combinedConfidence;
  final DateTime timestamp;

  const ThreatAssessment({
    required this.level,
    this.voiceEvent,
    this.motionEvent,
    required this.combinedConfidence,
    required this.timestamp,
  });

  bool get isMultiModal => voiceEvent != null && motionEvent != null;

  @override
  String toString() =>
      'Threat(${level.name}, confidence: ${(combinedConfidence * 100).toStringAsFixed(1)}%, multiModal: $isMultiModal)';
}

enum _SignalLevel { none, low, high }
