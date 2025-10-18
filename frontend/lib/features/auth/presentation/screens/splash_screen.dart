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
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.34, curve: Curves.easeOutCubic),
      ),
    );
    _pulseAnimation = AlwaysStoppedAnimation<double>(1.0);

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.82, curve: Curves.easeIn),
      ),
    );

    _shineAnimation = Tween<double>(begin: -1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.58, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().whenComplete(() {
      if (mounted) widget.onComplete();
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
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.18 * _glowAnimation.value),
                                blurRadius: 28 * _glowAnimation.value,
                                spreadRadius: 6 * _glowAnimation.value,
                              ),
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.24 * _glowAnimation.value),
                                blurRadius: 40 * _glowAnimation.value,
                                spreadRadius: 3 * _glowAnimation.value,
                              ),
                            ],
                          ),
                        ),
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
                                            Colors.white.withOpacity(0.28),
                                            Colors.white.withOpacity(0.48),
                                            Colors.white.withOpacity(0.28),
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
              // Text with synchronized glassy shine using the same _shineAnimation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // current shine value from -1.0 .. 1.5
                  final shine = _shineAnimation.value;

                  return Opacity(
                    opacity: _controller.value,
                    child: LayoutBuilder(builder: (context, constraints) {
                      return ShaderMask(
                        blendMode: BlendMode.srcATop,
                        shaderCallback: (Rect bounds) {
                          final width = bounds.width;
                          final travel = width + 80.0;
                          final dx = shine * travel;

                          return LinearGradient(
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
                          ).createShader(Rect.fromLTWH(dx - width, 0, width * 2, bounds.height));
                        },
                        child: const Text(
                          'CaseMate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}