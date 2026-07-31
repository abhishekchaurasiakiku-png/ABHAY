import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Animated pulsing SOS emergency button with hold-to-activate.
///
/// Features:
/// - Pulsing ring animation when idle
/// - Hold-to-activate with progress indicator
/// - Haptic feedback on activation
/// - Ripple effect on tap
class SosButton extends StatefulWidget {
  final VoidCallback onActivated;
  final bool isActive;
  final double size;

  const SosButton({
    super.key,
    required this.onActivated,
    this.isActive = false,
    this.size = 140,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _holdController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _holdAnimation;

  bool _isHolding = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _holdAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _holdController, curve: Curves.easeOut),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onActivated();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _holdController.dispose();
    super.dispose();
  }

  void _onPanDown(DragDownDetails _) {
    if (widget.isActive) return;
    setState(() => _isHolding = true);
    HapticFeedback.mediumImpact();
    _holdController.forward();
  }

  void _onPanCancel() {
    setState(() => _isHolding = false);
    _holdController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _holdAnimation]),
      builder: (context, child) {
        final scale = widget.isActive ? 1.0 : _pulseAnimation.value;

        return Transform.scale(
          scale: _isHolding ? 0.95 : scale,
          child: GestureDetector(
            onPanDown: _onPanDown,
            onPanCancel: _onPanCancel,
            onPanEnd: (_) => _onPanCancel(),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isActive
                    ? AppColors.emergencyGradient
                    : const LinearGradient(
                        colors: [Color(0xFFFF3B5C), Color(0xFFFF1744)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency.withValues(alpha: 0.4),
                    blurRadius: widget.isActive ? 30 : 20,
                    spreadRadius: widget.isActive ? 5 : 0,
                  ),
                  BoxShadow(
                    color: AppColors.emergency.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hold progress indicator
                  if (_isHolding)
                    SizedBox(
                      width: widget.size - 10,
                      height: widget.size - 10,
                      child: CircularProgressIndicator(
                        value: _holdAnimation.value,
                        strokeWidth: 4,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),

                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isActive ? Icons.warning_rounded : Icons.shield,
                        color: Colors.white,
                        size: widget.size * 0.3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.isActive ? 'ACTIVE' : 'SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.size * 0.14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      if (!widget.isActive)
                        Text(
                          'HOLD',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: widget.size * 0.08,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
