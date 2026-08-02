import 'dart:math';

import 'package:aklatna/core/services/onboarding_service.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingItem {
  final String titleStart;
  final String titleHighlight;
  final String titleEnd;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.titleStart,
    required this.titleHighlight,
    required this.titleEnd,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageValue = 0;

  // Continuous slow float for the illustration on the current page —
  // purely decorative, gives the screen life even when the user isn't
  // swiping. Used for pages 0 and 1.
  late final AnimationController _floatController;

  // Drive-across loop for the delivery scooter on the last page: drives
  // off to the right, then re-enters from the left back to center.
  late final AnimationController _driveController;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      titleStart: 'مرحباً بك في عالم من\n',
      titleHighlight: 'أشهى الأطباق',
      titleEnd: ' المتنوعة!',
      description:
          'اكتشف قائمة متنوعة من الأطباق اللذيذة من أفضل المطاعم القريبة منك. طعام شهي على بعد كبسة زر!',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      titleStart: 'اطلب وجباتك\n',
      titleHighlight: 'المفضلة',
      titleEnd: ' بلمسات بسيطة',
      description:
          'اطلب وجبتك المفضلة بكل سهولة وأمان. اختر المطعم، أضف إلى السلة، واستمتع بأشهى المأكولات!',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      titleStart: '',
      titleHighlight: 'تتبع طلبك',
      titleEnd: ' بسهولة وسرعة\nمن المطبخ لمنزلك',
      description:
          'تابع حالة طلبك خطوة بخطوة من المطبخ وحتى باب منزلك عبر خدمة التتبع المباشر. طعام طازج في الوقت المحدد!',
      imagePath: 'assets/images/onboarding_3.png',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _driveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _pageController.addListener(() {
      setState(() {
        _pageValue = _pageController.page ?? 0;
      });
    });
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _navigateToAuth(String route) async {
    await OnboardingService.markAsCompleted();
    if (!mounted) return;
    context.go(route);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _driveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ================= TOP BAR (تخطي) =================
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  right: 20.0,
                  left: 20.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedOpacity(
                    opacity: isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLastPage
                          ? null
                          : () => _navigateToAuth('/signin'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'تخطي',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ================= SLIDER CONTENT =================
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];

                    // Parallax: pages scale/fade based on distance from
                    // the currently centered page as you swipe.
                    final distance = (index - _pageValue).abs();
                    final scale = (1 - (distance * 0.15)).clamp(0.85, 1.0);
                    final opacity = (1 - (distance * 0.6)).clamp(0.3, 1.0);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28.0,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                    fontFamily: 'Cairo',
                                  ),
                                  children: [
                                    TextSpan(text: item.titleStart),
                                    TextSpan(
                                      text: item.titleHighlight,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    TextSpan(text: item.titleEnd),
                                  ],
                                ),
                              ),

                              // صورة التوضيح — last page (scooter) gets
                              // a drive-off-and-return loop, other pages
                              // get a gentle continuous float.
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                  ),
                                  child: index == 2
                                      ? _buildDrivingIllustration(
                                          context,
                                          item,
                                        )
                                      : AnimatedBuilder(
                                          animation: _floatController,
                                          builder: (context, child) {
                                            final isActive =
                                                index == _currentPage;

                                            final floatOffset = isActive
                                                ? sin(
                                                      _floatController
                                                              .value *
                                                          2 *
                                                          pi,
                                                    ) *
                                                    8
                                                : 0.0;

                                            return Transform.translate(
                                              offset:
                                                  Offset(0, floatOffset),
                                              child: child,
                                            );
                                          },
                                          child: Image.asset(
                                            item.imagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) =>
                                                Center(
                                              child: Icon(
                                                index == 0
                                                    ? Icons.restaurant_menu
                                                    : Icons
                                                        .mobile_screen_share,
                                                size: 130,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ================= BOTTOM CONTROLS =================
              Padding(
                padding: const EdgeInsets.only(
                  left: 28.0,
                  right: 28.0,
                  bottom: 24.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.92, end: 1.0)
                            .animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isLastPage
                      ? _buildLastPageControls()
                      : _buildPageNavControls(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DRIVING ILLUSTRATION (last page — scooter)
  // ============================================================
  //
  // Loop: drives off to the right (55% of the loop), then instantly
  // repositions off-screen to the left and drives back in to center
  // (remaining 45%). Opacity dips to 0 during the reposition jump so
  // the teleport isn't visible — reads as "drove off, then comes back
  // around."
  // ============================================================

  Widget _buildDrivingIllustration(BuildContext context, OnboardingItem item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final travelDistance = screenWidth * 0.75;

    return AnimatedBuilder(
      animation: _driveController,
      builder: (context, child) {
        final t = _driveController.value;

        double dx;
        double opacity;

        const driveOutEnd = 0.55; // portion of loop spent driving right
        const gapEnd = 0.62; // brief invisible reposition window
        const driveInEnd = 1.0; // portion spent driving back in from left

        if (t < driveOutEnd) {
          // Driving off to the right, fading out near the end.
          final localT = t / driveOutEnd;
          dx = travelDistance * Curves.easeIn.transform(localT);
          opacity = localT < 0.75 ? 1.0 : (1.0 - (localT - 0.75) / 0.25);
        } else if (t < gapEnd) {
          // Invisible — repositioned off-screen left.
          dx = -travelDistance;
          opacity = 0.0;
        } else {
          // Driving back in from the left to center, fading in.
          final localT = (t - gapEnd) / (driveInEnd - gapEnd);
          dx = -travelDistance * (1 - Curves.easeOut.transform(localT));
          opacity = localT < 0.25 ? (localT / 0.25) : 1.0;
        }

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          ),
        );
      },
      child: Image.asset(
        item.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(
            Icons.delivery_dining,
            size: 130,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageNavControls() {
    return Row(
      key: const ValueKey('nav_controls'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: _currentPage > 0
              ? _CircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: _previousPage,
                )
              : null,
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _items.length,
            (index) => _DotIndicator(isActive: index == _currentPage),
          ),
        ),

        SizedBox(
          width: 44,
          height: 44,
          child: _CircleIconButton(
            icon: Icons.arrow_forward,
            onTap: _nextPage,
          ),
        ),
      ],
    );
  }

  Widget _buildLastPageControls() {
    return Row(
      key: const ValueKey('last_page_controls'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth('/signin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _items.length,
              (index) => _DotIndicator(isActive: index == _currentPage),
            ),
          ),
        ),

        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'إنشاء حساب',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// WIDGETS
// ============================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}