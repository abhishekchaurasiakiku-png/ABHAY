import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Service for multi-modal motion & context analysis.
///
/// Uses the smartphone's accelerometer and gyroscope to detect
/// abnormal physical movements such as falls, struggles, and phone grabs.
///
/// The ML model differentiates between:
/// - Normal activities (walking, running, phone in pocket)
/// - Phone drop (sudden freefall → impact)
/// - Physical struggle (irregular, high-g movements)
/// - Sudden fall (freefall → impact → stillness)
/// - Phone snatch (sudden jerky movement away from body)
class MotionAnalysisService {
  bool _isMonitoring = false;
  double _sensitivity = 0.70;

  StreamSubscription? _accelSubscription;
  StreamSubscription? _gyroSubscription;

  // Rolling window of sensor data for pattern analysis
  final List<_SensorFrame> _frameBuffer = [];
  static const int _bufferSize = 100; // ~2 seconds at 50Hz
  static const Duration _analysisInterval = Duration(milliseconds: 500);

  Timer? _analysisTimer;

  final _anomalyController = StreamController<MotionAnomalyEvent>.broadcast();
  final _statusController = StreamController<MotionMonitorStatus>.broadcast();

  /// Stream of motion anomaly events.
  Stream<MotionAnomalyEvent> get anomalyEvents => _anomalyController.stream;

  /// Stream of monitoring status changes.
  Stream<MotionMonitorStatus> get statusChanges => _statusController.stream;

  bool get isMonitoring => _isMonitoring;

  /// Start monitoring accelerometer and gyroscope data.
  Future<void> startMonitoring({double? sensitivity}) async {
    if (_isMonitoring) return;

    if (sensitivity != null) _sensitivity = sensitivity;

    _isMonitoring = true;
    _statusController.add(MotionMonitorStatus.active);
    _frameBuffer.clear();

    // Subscribe to accelerometer data
    _accelSubscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 20), // 50Hz
    ).listen((event) {
      _addFrame(
        accelX: event.x,
        accelY: event.y,
        accelZ: event.z,
      );
    });

    // Subscribe to gyroscope data
    _gyroSubscription = gyroscopeEventStream(
      samplingPeriod: const Duration(milliseconds: 20),
    ).listen((event) {
      _updateLatestGyro(
        gyroX: event.x,
        gyroY: event.y,
        gyroZ: event.z,
      );
    });

    // Periodic analysis of the sensor buffer
    _analysisTimer = Timer.periodic(_analysisInterval, (_) => _analyzeBuffer());

    print('[MotionAnalysis] Monitoring started (sensitivity: $_sensitivity)');
  }

  /// Stop motion monitoring.
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    _isMonitoring = false;
    _analysisTimer?.cancel();
    await _accelSubscription?.cancel();
    await _gyroSubscription?.cancel();
    _frameBuffer.clear();
    _statusController.add(MotionMonitorStatus.inactive);

    print('[MotionAnalysis] Monitoring stopped');
  }

  /// Update detection sensitivity (0.0 to 1.0).
  void setSensitivity(double value) {
    _sensitivity = value.clamp(0.0, 1.0);
  }

  /// Simulate a motion anomaly for testing.
  void simulateAnomaly(MotionAnomalyType type, {double confidence = 0.85}) {
    final event = MotionAnomalyEvent(
      type: type,
      confidence: confidence,
      timestamp: DateTime.now(),
      peakAcceleration: type == MotionAnomalyType.fall ? 25.0 : 18.0,
      duration: const Duration(seconds: 2),
    );
    _anomalyController.add(event);
  }

  void _addFrame({
    required double accelX,
    required double accelY,
    required double accelZ,
  }) {
    _frameBuffer.add(_SensorFrame(
      timestamp: DateTime.now(),
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
    ));

    // Keep buffer within size limit
    if (_frameBuffer.length > _bufferSize) {
      _frameBuffer.removeAt(0);
    }
  }

  void _updateLatestGyro({
    required double gyroX,
    required double gyroY,
    required double gyroZ,
  }) {
    if (_frameBuffer.isNotEmpty) {
      _frameBuffer.last.gyroX = gyroX;
      _frameBuffer.last.gyroY = gyroY;
      _frameBuffer.last.gyroZ = gyroZ;
    }
  }

  /// Analyze the rolling buffer for motion anomalies.
  void _analyzeBuffer() {
    if (!_isMonitoring || _frameBuffer.length < 20) return;

    // Production: Feed the buffer into a TFLite model trained on
    // IMU data for activity recognition.
    //
    // Model architecture:
    // - Input: 100 frames × 6 features (accelXYZ + gyroXYZ)
    // - Architecture: 1D-CNN + LSTM for temporal patterns
    // - Output: [normal, fall, struggle, phone_drop, phone_snatch]
    // - Size: < 1.5MB

    // Development: Rule-based anomaly detection
    final recentFrames = _frameBuffer.sublist(
      max(0, _frameBuffer.length - 50),
    );

    // Calculate acceleration magnitude for each frame
    final magnitudes = recentFrames.map((f) {
      return sqrt(f.accelX * f.accelX + f.accelY * f.accelY + f.accelZ * f.accelZ);
    }).toList();

    final avgMagnitude = magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    final maxMagnitude = magnitudes.reduce(max);
    final minMagnitude = magnitudes.reduce(min);

    // Calculate variance (irregularity)
    final variance = magnitudes.map((m) => (m - avgMagnitude) * (m - avgMagnitude)).reduce((a, b) => a + b) / magnitudes.length;
    final stdDev = sqrt(variance);

    // Threshold-based detection (adjusted by sensitivity)
    final freefallThreshold = 2.0 * (1.0 - _sensitivity + 0.3);
    final impactThreshold = 20.0 * _sensitivity;
    final struggleVarianceThreshold = 15.0 * _sensitivity;

    // Detect freefall → impact (fall or phone drop)
    if (minMagnitude < freefallThreshold && maxMagnitude > impactThreshold) {
      // Check for post-impact stillness (fall) vs recovery (phone drop)
      final lastFrames = magnitudes.sublist(max(0, magnitudes.length - 10));
      final lastAvg = lastFrames.reduce((a, b) => a + b) / lastFrames.length;

      final type = lastAvg < 10.0
          ? MotionAnomalyType.fall
          : MotionAnomalyType.phoneDrop;

      final confidence = (maxMagnitude / 30.0).clamp(0.5, 1.0);

      _anomalyController.add(MotionAnomalyEvent(
        type: type,
        confidence: confidence,
        timestamp: DateTime.now(),
        peakAcceleration: maxMagnitude,
        duration: Duration(
          milliseconds: recentFrames.last.timestamp
              .difference(recentFrames.first.timestamp)
              .inMilliseconds,
        ),
      ));
      return;
    }

    // Detect physical struggle (sustained high variance)
    if (stdDev > struggleVarianceThreshold && avgMagnitude > 12.0) {
      // Check gyroscope for rotation (struggle has erratic rotation)
      final gyroMagnitudes = recentFrames
          .where((f) => f.gyroX != null)
          .map((f) => sqrt(f.gyroX! * f.gyroX! + f.gyroY! * f.gyroY! + f.gyroZ! * f.gyroZ!))
          .toList();

      if (gyroMagnitudes.isNotEmpty) {
        final avgGyro = gyroMagnitudes.reduce((a, b) => a + b) / gyroMagnitudes.length;

        if (avgGyro > 3.0) {
          _anomalyController.add(MotionAnomalyEvent(
            type: MotionAnomalyType.struggle,
            confidence: (stdDev / 25.0).clamp(0.5, 1.0),
            timestamp: DateTime.now(),
            peakAcceleration: maxMagnitude,
            duration: const Duration(seconds: 2),
          ));
          return;
        }
      }
    }

    // Detect phone snatch (sudden high-g jerk)
    if (magnitudes.length >= 3) {
      for (int i = 2; i < magnitudes.length; i++) {
        final jerk = (magnitudes[i] - magnitudes[i - 2]).abs();
        if (jerk > 25.0 * _sensitivity) {
          _anomalyController.add(MotionAnomalyEvent(
            type: MotionAnomalyType.phoneSnatch,
            confidence: (jerk / 40.0).clamp(0.5, 1.0),
            timestamp: DateTime.now(),
            peakAcceleration: maxMagnitude,
            duration: const Duration(milliseconds: 500),
          ));
          return;
        }
      }
    }
  }

  void dispose() {
    stopMonitoring();
    _anomalyController.close();
    _statusController.close();
  }
}

/// Internal sensor data frame.
class _SensorFrame {
  final DateTime timestamp;
  final double accelX;
  final double accelY;
  final double accelZ;
  double? gyroX;
  double? gyroY;
  double? gyroZ;

  _SensorFrame({
    required this.timestamp,
    required this.accelX,
    required this.accelY,
    required this.accelZ,
  });
}

/// Types of motion anomalies detected.
enum MotionAnomalyType {
  fall,         // Sudden fall with post-impact stillness
  struggle,     // Erratic, high-g movements with rotation
  phoneDrop,    // Freefall → impact → recovery
  phoneSnatch,  // Sudden high-jerk movement
  running,      // Detected but not treated as anomaly unless combined
}

/// Status of motion monitoring.
enum MotionMonitorStatus {
  active,
  inactive,
  initializing,
  error,
}

/// Event emitted when a motion anomaly is detected.
class MotionAnomalyEvent {
  final MotionAnomalyType type;
  final double confidence;       // 0.0 to 1.0
  final DateTime timestamp;
  final double peakAcceleration; // m/s²
  final Duration duration;

  const MotionAnomalyEvent({
    required this.type,
    required this.confidence,
    required this.timestamp,
    required this.peakAcceleration,
    required this.duration,
  });

  bool get isHighConfidence => confidence >= 0.80;

  @override
  String toString() =>
      'MotionAnomaly(${type.name}, confidence: ${(confidence * 100).toStringAsFixed(1)}%, peak: ${peakAcceleration.toStringAsFixed(1)} m/s²)';
}
