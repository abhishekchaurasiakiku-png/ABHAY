import 'package:flutter/material.dart';
import 'dart:async';

/// Full-screen fake incoming call UI.
///
/// Mimics a real phone call with answer/decline buttons,
/// in-call timer, and speaker toggle.
class FakeCallScreen extends StatefulWidget {
  final String callerName;
  final String callerNumber;

  const FakeCallScreen({
    super.key,
    this.callerName = 'Mom',
    this.callerNumber = '+91 98765 43210',
  });

  @override
  State<FakeCallScreen> createState() => _FakeCallScreenState();
}

class _FakeCallScreenState extends State<FakeCallScreen>
    with TickerProviderStateMixin {
  bool _isAnswered = false;
  bool _isSpeakerOn = false;
  bool _isMuted = false;
  int _callDuration = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _answerCall() {
    setState(() => _isAnswered = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _callDuration++);
    });
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Caller avatar
            ScaleTransition(
              scale: _isAnswered
                  ? const AlwaysStoppedAnimation(1.0)
                  : Tween(begin: 0.95, end: 1.05).animate(
                      CurvedAnimation(
                        parent: _pulseController,
                        curve: Curves.easeInOut,
                      ),
                    ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5B52E0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.callerName.isNotEmpty
                        ? widget.callerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Caller name
            Text(
              widget.callerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            // Status / Number
            Text(
              _isAnswered
                  ? _formatDuration(_callDuration)
                  : widget.callerNumber,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),

            if (!_isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Incoming call...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ),

            const Spacer(flex: 2),

            // In-call controls
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: 'Mute',
                      isActive: _isMuted,
                      onTap: () => setState(() => _isMuted = !_isMuted),
                    ),
                    _CallButton(
                      icon: Icons.dialpad,
                      label: 'Keypad',
                      onTap: () {},
                    ),
                    _CallButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      label: 'Speaker',
                      isActive: _isSpeakerOn,
                      onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                    ),
                  ],
                ),
              ),

            const Spacer(),

            // Answer / Decline buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 48),
              child: _isAnswered
                  ? _EndCallButton(onTap: _endCall)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decline
                        _CircleCallButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          label: 'Decline',
                          onTap: _endCall,
                        ),
                        // Answer
                        _CircleCallButton(
                          icon: Icons.call,
                          color: Colors.green,
                          label: 'Answer',
                          onTap: _answerCall,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleCallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _CircleCallButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EndCallButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EndCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.call_end, color: Colors.white, size: 30),
      ),
    );
  }
}
