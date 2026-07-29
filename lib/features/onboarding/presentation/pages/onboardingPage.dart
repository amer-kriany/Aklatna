import 'package:aklatna/core/constants/app_spacing.dart';
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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _items.length - 1;

    return Directionality(
      textDirection: TextDirection.rtl, // دعم الاتجاه العربي
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // ================= TOP BAR (تخطي) =================
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 20.0, left: 20.0),
                child: Align(
                  alignment: Alignment.centerLeft, // زر تخطي على اليسار في العربي
                  child: AnimatedOpacity(
                    opacity: isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: isLastPage
                          ? null
                          : () => _navigateToAuth('/signin'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6B2C),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(40, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'تخطي',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF6B2C),
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
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // العنوان مع التظليل
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF222222),
                                height: 1.3,
                                fontFamily: 'Cairo', // أو الخط المستخدم في تطبيقك
                              ),
                              children: [
                                TextSpan(text: item.titleStart),
                                TextSpan(
                                  text: item.titleHighlight,
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B2C),
                                  ),
                                ),
                                TextSpan(text: item.titleEnd),
                              ],
                            ),
                          ),

                          // صورة التوضيح
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Image.asset(
                                item.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Icon(
                                    index == 0
                                        ? Icons.restaurant_menu
                                        : index == 1
                                            ? Icons.mobile_screen_share
                                            : Icons.delivery_dining,
                                    size: 130,
                                    color: const Color(0xFFFF6B2C),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // الوصف الفرعي
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA0A0A0),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),
                        ],
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

  // التحكم للصفحات 1 و 2
  Widget _buildPageNavControls() {
    return Row(
      key: const ValueKey('nav_controls'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر الرجوع (يختفي في الصفحة الأولى)
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

        // النقاط التوضيحية
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            _items.length,
            (index) => _DotIndicator(isActive: index == _currentPage),
          ),
        ),

        // زر التالي
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

  // التحكم للصفحة الأخيرة (تسجيل الدخول / إنشاء حساب)
  Widget _buildLastPageControls() {
    return Row(
      key: const ValueKey('last_page_controls'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // زر تسجيل الدخول
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth('/signin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEFEFEF),
                foregroundColor: const Color(0xFF222222),
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

        // النقاط في المنتصف
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

        // زر إنشاء حساب
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B2C),
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
// WIDGETS MASHUP
// ============================================================

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFF6B2C),
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
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      height: 6,
      width: isActive ? 18 : 6,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFFF6B2C) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}