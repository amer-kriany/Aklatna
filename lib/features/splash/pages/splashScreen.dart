import 'dart:async';

import 'package:aklatna/core/services/app_update_checker.dart';
import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/services/onboarding_service.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/core/widgets/skeleton.dart';
import 'package:aklatna/features/auth/presentation/bloc/bloc/auth_bloc.dart';
import 'package:aklatna/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _breatheController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _breatheAnimation;

  static const Color _bgColor = Color(0xFFF3E7D8);

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Slow, gentle breathing scale once the logo has settled in —
    // subtle enough to feel alive without being distracting.
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _breatheAnimation = Tween<double>(begin: 1.0, end: 1.035).animate(
      CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
    );

    _entranceController.forward().then((_) {
      _breatheController.repeat(reverse: true);
    });

    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
  await Future.delayed(const Duration(seconds: 3));

  if (!mounted) return;

  final bool hasCompletedOnboarding = await OnboardingService.isCompleted();

  if (!hasCompletedOnboarding) {
    context.go('/onboarding');
    return;
  }

  // Await the update check so it can show its dialog BEFORE we
  // navigate away from splash — otherwise the context becomes
  // unmounted mid-request and the dialog silently never shows.
  if (mounted) {
    await AppUpdateChecker.checkForUpdate(context);
  }

  if (!mounted) return;

  sl<AuthBloc>().add(GetCurrentUserEvent());
}

  @override
  void dispose() {
    _entranceController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _breatheController,
                      builder: (context, child) {
                        final breathe = _breatheController.isAnimating
                            ? _breatheAnimation.value
                            : 1.0;
                        return Transform.scale(scale: breathe, child: child);
                      },
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.restaurant_rounded,
                          size: 120,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'أكلاتنا',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Cairo',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'طعم داريا الأصيل',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Minimal loading indicator — keeps the bottom from feeling
          // dead while the entrance/breathe animations play out.
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Skeleton(
                  width: 90,
                  height: 10,
                  radius: AppRadius.full,
                  baseColor: AppColors.shimmerBase,
                  highlightColor: AppColors.shimmerHighlight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}