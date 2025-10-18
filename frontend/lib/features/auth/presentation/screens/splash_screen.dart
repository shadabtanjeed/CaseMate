import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Initial emerge animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );

    // Gentle throb/pulse animation
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1.0,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeInOut),
      ),
    );

    // Glow intensity animation
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.85, curve: Curves.easeIn),
      ),
    );

    // Glass shine effect - completes before transition
    _shineAnimation = Tween<double>(begin: -1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.95, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Delay increased to allow shine to complete
    Future.delayed(const Duration(milliseconds: 2800), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.darkBlue, AppTheme.primaryBlue],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = _scaleAnimation.value * _pulseAnimation.value;
                  
                  return Transform.scale(
                    scale: scale,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow effect
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 10 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4 * _glowAnimation.value),
                                blurRadius: 60 * _glowAnimation.value,
                                spreadRadius: 5 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        ),
                        // Main container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.balance,
                                  size: 64,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              // Glass shine effect
                              if (_shineAnimation.value > -1.0 && _shineAnimation.value < 1.5)
                                Positioned.fill(
                                  child: Transform.translate(
                                    offset: Offset(_shineAnimation.value * 120, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.transparent,
                                            Colors.white.withOpacity(0.4),
                                            Colors.white.withOpacity(0.6),
                                            Colors.white.withOpacity(0.4),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _controller,
                child: const Text(
                  'CaseMate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}