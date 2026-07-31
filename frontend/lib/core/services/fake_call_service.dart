import 'dart:async';
import 'package:flutter/material.dart';

/// Service for simulating a fake incoming phone call.
///
/// Triggered by the AI engine when a MEDIUM threat level is detected
/// (e.g., awkward lingering but no physical struggle). Provides the
/// user with a believable excuse to leave a situation.
class FakeCallService {
  Timer? _ringTimer;
  bool _isRinging = false;
  bool _isInCall = false;

  final _callEventController = StreamController<FakeCallEvent>.broadcast();

  /// Stream of fake call events.
  Stream<FakeCallEvent> get callEvents => _callEventController.stream;

  bool get isRinging => _isRinging;
  bool get isInCall => _isInCall;

  /// Trigger a fake incoming call after [delay].
  ///
  /// [callerName] and [callerNumber] customize the call screen.
  /// [delay] allows scheduling the call (e.g., "call me in 30 seconds").
  Future<void> triggerFakeCall({
    String callerName = 'Mom',
    String callerNumber = '+91 98765 43210',
    Duration delay = Duration.zero,
  }) async {
    if (_isRinging || _isInCall) return;

    if (delay > Duration.zero) {
      _ringTimer = Timer(delay, () {
        _startRinging(callerName, callerNumber);
      });
      print('[FakeCall] Scheduled in ${delay.inSeconds}s from "$callerName"');
    } else {
      _startRinging(callerName, callerNumber);
    }
  }

  void _startRinging(String callerName, String callerNumber) {
    _isRinging = true;

    _callEventController.add(FakeCallEvent(
      type: FakeCallEventType.ringing,
      callerName: callerName,
      callerNumber: callerNumber,
    ));

    // In production: play ringtone using audio player
    // and trigger vibration using haptic feedback.

    print('[FakeCall] 📞 Incoming call from "$callerName"');

    // Auto-stop ringing after 30 seconds if not answered
    _ringTimer = Timer(const Duration(seconds: 30), () {
      if (_isRinging) {
        endCall();
      }
    });
  }

  /// Answer the fake call — switches to in-call UI.
  void answerCall() {
    if (!_isRinging) return;

    _isRinging = false;
    _isInCall = true;
    _ringTimer?.cancel();

    _callEventController.add(FakeCallEvent(
      type: FakeCallEventType.answered,
      callerName: '',
      callerNumber: '',
    ));

    print('[FakeCall] Call answered');
  }

  /// Decline or end the fake call.
  void endCall() {
    _isRinging = false;
    _isInCall = false;
    _ringTimer?.cancel();

    _callEventController.add(FakeCallEvent(
      type: FakeCallEventType.ended,
      callerName: '',
      callerNumber: '',
    ));

    print('[FakeCall] Call ended');
  }

  /// Cancel a scheduled fake call.
  void cancelScheduledCall() {
    _ringTimer?.cancel();
    _isRinging = false;
    print('[FakeCall] Scheduled call cancelled');
  }

  /// Predefined caller presets for quick access.
  static const List<FakeCallerPreset> callerPresets = [
    FakeCallerPreset(name: 'Mom', number: '+91 98765 43210', icon: Icons.favorite),
    FakeCallerPreset(name: 'Dad', number: '+91 98765 43211', icon: Icons.person),
    FakeCallerPreset(name: 'Home', number: '+91 11 2345 6789', icon: Icons.home),
    FakeCallerPreset(name: 'Boss', number: '+91 98765 43212', icon: Icons.work),
    FakeCallerPreset(name: 'Best Friend', number: '+91 98765 43213', icon: Icons.group),
  ];

  void dispose() {
    _ringTimer?.cancel();
    _callEventController.close();
  }
}

/// Types of fake call events.
enum FakeCallEventType {
  ringing,
  answered,
  ended,
  declined,
}

/// Event from the fake call service.
class FakeCallEvent {
  final FakeCallEventType type;
  final String callerName;
  final String callerNumber;

  const FakeCallEvent({
    required this.type,
    required this.callerName,
    required this.callerNumber,
  });
}

/// Predefined fake caller preset.
class FakeCallerPreset {
  final String name;
  final String number;
  final IconData icon;

  const FakeCallerPreset({
    required this.name,
    required this.number,
    required this.icon,
  });
}
