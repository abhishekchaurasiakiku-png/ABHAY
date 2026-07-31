import 'dart:async';
import 'dart:math';

/// Service for always-on voice distress detection.
///
/// Uses a background audio listener to detect distress keywords
/// and sustained screams. In production, this would use TensorFlow Lite
/// with MFCC feature extraction for on-device inference.
///
/// Privacy: All audio processing happens strictly on-device.
/// Audio is never sent to the backend unless an active SOS is triggered.
class VoiceDistressService {
  bool _isListening = false;
  double _sensitivity = 0.75;
  Timer? _analysisTimer;

  final _distressController = StreamController<VoiceDistressEvent>.broadcast();
  final _statusController = StreamController<VoiceListenerStatus>.broadcast();

  /// Stream of distress detection events.
  Stream<VoiceDistressEvent> get distressEvents => _distressController.stream;

  /// Stream of listener status changes.
  Stream<VoiceListenerStatus> get statusChanges => _statusController.stream;

  bool get isListening => _isListening;

  /// Default distress keywords for detection.
  List<String> distressKeywords = [
    'help me',
    'save me',
    'bachao',
    'please help',
    'somebody help',
    'let me go',
    'stop it',
    'help',
  ];

  /// Start the always-on voice distress listener.
  ///
  /// Uses a low-power background service to minimize battery impact.
  /// Target: < 3-5% battery per hour.
  Future<void> startListening({double? sensitivity}) async {
    if (_isListening) return;

    if (sensitivity != null) _sensitivity = sensitivity;

    _isListening = true;
    _statusController.add(VoiceListenerStatus.active);

    // In production: initialize the audio recorder in low-power mode
    // and feed audio chunks to the TFLite model for inference.
    //
    // The implementation would:
    // 1. Use a background isolate with `record` package
    // 2. Extract MFCC features from audio frames
    // 3. Run TFLite model inference on features
    // 4. Compare against distress keyword embeddings
    // 5. Detect sustained high-dB screams via amplitude analysis

    // Development simulation: periodic analysis cycle
    _analysisTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _runAnalysisCycle(),
    );

    print('[VoiceDistress] Listening started (sensitivity: $_sensitivity)');
  }

  /// Stop the voice distress listener.
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    _analysisTimer?.cancel();
    _statusController.add(VoiceListenerStatus.inactive);

    print('[VoiceDistress] Listening stopped');
  }

  /// Update detection sensitivity (0.0 to 1.0).
  void setSensitivity(double value) {
    _sensitivity = value.clamp(0.0, 1.0);
  }

  /// Update distress keywords.
  void setKeywords(List<String> keywords) {
    distressKeywords = keywords;
  }

  /// Simulate a distress detection for testing.
  void simulateDistress(VoiceDistressType type, {double confidence = 0.9}) {
    final event = VoiceDistressEvent(
      type: type,
      confidence: confidence,
      timestamp: DateTime.now(),
      detectedKeyword: type == VoiceDistressType.keyword ? 'help me' : null,
      decibelLevel: type == VoiceDistressType.scream ? 95.0 : 60.0,
    );
    _distressController.add(event);
  }

  /// Internal analysis cycle — in production this would run TFLite inference.
  void _runAnalysisCycle() {
    if (!_isListening) return;

    // Production implementation would:
    // 1. Capture audio buffer (last 2-3 seconds)
    // 2. Extract MFCC features (13 coefficients, 40 mel filters)
    // 3. Run Sinc-CNN or similar lightweight model
    // 4. Output: keyword match probability, scream probability, ambient noise level
    // 5. Apply sensitivity threshold
    // 6. Emit VoiceDistressEvent if above threshold

    // The model architecture for production:
    // - Input: 2-second audio window, 16kHz sample rate
    // - Feature extraction: 13 MFCCs + delta + delta-delta = 39 features
    // - Model: 3-layer CNN with depthwise separable convolutions
    // - Output: [keyword_prob, scream_prob, normal_prob]
    // - Size: < 2MB for minimal battery/memory impact
  }

  /// Analyze a specific audio buffer (for manual/triggered analysis).
  Future<VoiceDistressEvent?> analyzeAudioBuffer(List<int> audioData) async {
    // Production: run TFLite inference on the audio buffer
    // Returns null if no distress detected

    // Placeholder: amplitude-based scream detection
    if (audioData.isEmpty) return null;

    final maxAmplitude = audioData.reduce(max).toDouble();
    final normalizedAmplitude = maxAmplitude / 32768.0; // 16-bit audio

    if (normalizedAmplitude > _sensitivity) {
      return VoiceDistressEvent(
        type: VoiceDistressType.scream,
        confidence: normalizedAmplitude,
        timestamp: DateTime.now(),
        decibelLevel: 20 * log(normalizedAmplitude) / ln10 + 90,
      );
    }

    return null;
  }

  void dispose() {
    stopListening();
    _distressController.close();
    _statusController.close();
  }
}

/// Types of voice distress that can be detected.
enum VoiceDistressType {
  keyword,  // Specific distress phrase detected
  scream,   // Sustained high-dB scream detected
  cry,      // Sustained crying detected
}

/// Status of the voice listener service.
enum VoiceListenerStatus {
  active,
  inactive,
  initializing,
  error,
}

/// Event emitted when voice distress is detected.
class VoiceDistressEvent {
  final VoiceDistressType type;
  final double confidence;     // 0.0 to 1.0
  final DateTime timestamp;
  final String? detectedKeyword;
  final double? decibelLevel;

  const VoiceDistressEvent({
    required this.type,
    required this.confidence,
    required this.timestamp,
    this.detectedKeyword,
    this.decibelLevel,
  });

  bool get isHighConfidence => confidence >= 0.80;

  @override
  String toString() =>
      'VoiceDistress(${type.name}, confidence: ${(confidence * 100).toStringAsFixed(1)}%)';
}
