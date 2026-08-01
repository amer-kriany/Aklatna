import 'dart:async';
import 'dart:math';

import 'package:aklatna/core/constants/app_assets.dart';
import 'package:aklatna/core/services/onboarding_service.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _dotsController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Slow-drifting background glow blobs — purely decorative movement
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Loading dots at the bottom
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Logo gives a small playful wobble as it settles in, instead of
    // just scaling straight up.
    _rotateAnimation = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.45, 0.85, curve: Curves.easeOutBack),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    final bool hasCompletedOnboarding = await OnboardingService.isCompleted();
    final session = Supabase.instance.client.auth.currentSession;

    if (!hasCompletedOnboarding) {
      context.go('/onboarding');
    } else if (session == null) {
      context.go('/signin');
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= DRIFTING BACKGROUND GLOWS =================
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final t = _glowController.value * 2 * pi;

                return Stack(
                  children: [
                    _glowBlob(
                      context,
                      dx: 0.15 + 0.05 * sin(t),
                      dy: 0.15 + 0.04 * cos(t),
                      size: 220,
                      opacity: 0.10,
                    ),
                    _glowBlob(
                      context,
                      dx: 0.85 + 0.04 * cos(t * 0.8),
                      dy: 0.85 + 0.05 * sin(t * 0.8),
                      size: 260,
                      opacity: 0.08,
                    ),
                  ],
                );
              },
            ),
          ),

          // ================= MAIN CONTENT =================
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ================= LOGO ANIMATION =================
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: Listenable.merge(
                        [_pulseController, _mainController],
                      ),
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Transform.scale(
                            scale: _mainController.isCompleted
                                ? _pulseAnimation.value
                                : 1.0,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 60,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logo,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (context, error, stackTrace) =>
                              Center(
                            child: Icon(
                              Icons.restaurant_rounded,
                              size: 140,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ================= TEXT ANIMATION (shimmer) =================
                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            final sweep = _glowController.value;

                            return LinearGradient(
                              begin: Alignment(-1 + sweep * 3, 0),
                              end: Alignment(1 + sweep * 3, 0),
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.5),
                                AppColors.primary,
                              ],
                              stops: const [0.35, 0.5, 0.65],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'أكلاتنا',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= LOADING DOTS =================
          Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: AnimatedBuilder(
                animation: _dotsController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final delay = index * 0.2;
                      final t =
                          ((_dotsController.value - delay) % 1.0 + 1.0) %
                              1.0;
                      final bounce = sin(t * pi).clamp(0.0, 1.0);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.translate(
                          offset: Offset(0, -8 * bounce),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary
                                  .withOpacity(0.4 + 0.6 * bounce),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowBlob(
    BuildContext context, {
    required double dx,
    required double dy,
    required double size,
    required double opacity,
  }) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: screenSize.width * dx - size / 2,
      top: screenSize.height * dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(opacity),
        ),
      ),
    );
  }
}