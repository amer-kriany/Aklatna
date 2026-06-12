class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'أكلاتنا';
  static const String appCity = 'داريا';

  // Local Storage / Shared Preferences Keys
  static const String prefsKeyTheme = 'theme_mode';
  static const String prefsKeyLanguage = 'language_code';
  static const String prefsKeyIsFirstTime = 'is_first_time';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Order Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusPreparing = 'preparing';
  static const String statusReady = 'ready';
  static const String statusPickedUp = 'picked_up';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Order Type
  static const String typeDelivery = 'delivery';
  static const String typePickup = 'pickup';

  // Restaurant Category
  static const String categoryRestaurant = 'restaurant';
  static const String categoryJuiceBar = 'juice_bar';
  static const String categorySweets = 'sweets';
  static const String categoryFastFood = 'fast_food';

  // User Role
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';
  static const String roleRestaurantOwner = 'owner';
  static const String roleDriver = 'driver';

  // Auth Text
  static const String authWelcomeMessage = 'مرحباً بك في عالم المذاق الأصيل';
  static const String authSignInTab = 'دخول';
  static const String authSignUpTab = 'إنشاء حساب';
  static const String authEmailOrPhoneLabel = 'البريد الإلكتروني أو رقم الهاتف';
  static const String authEmailOrPhoneHint = 'ادخل بريدك أو رقمك';
  static const String authEmailLabel = 'البريد الإلكتروني';
  static const String authEmailHint = 'ادخل بريدك الإلكتروني';
  static const String authOptionalEmailLabel = 'البريد الإلكتروني (اختياري)';
  static const String authUsernameLabel = 'اسم المستخدم';
  static const String authUsernameHint = 'ادخل اسم المستخدم';
  static const String authPhoneLabel = 'رقم الهاتف';
  static const String authPhoneHint = 'ادخل رقم هاتفك';
  static const String authPasswordLabel = 'كلمة المرور';
  static const String authPasswordHint = '••••••••';
  static const String authConfirmPasswordLabel = 'تأكيد كلمة المرور';
  static const String authRequiredFieldError = 'هذا الحقل مطلوب';
  static const String authEmailOrPhoneRequiredError =
      'اكتب البريد الإلكتروني أو رقم الهاتف';
  static const String authPasswordMismatchError = 'كلمتا المرور غير متطابقتين';
  static const String authForgotPassword = 'نسيت كلمة المرور؟';
  static const String authSignInWithEmail = 'الدخول بالبريد الإلكتروني';
  static const String authSignInWithPhone = 'الدخول برقم الهاتف';
  static const String authSignInAction = 'دخول';
  static const String authSignUpAction = 'إنشاء حساب';
  static const String authTermsPrefix = 'بالمتابعة، أنت توافق على ';
  static const String authTerms = 'الشروط والأحكام';
  static const String authTermsJoiner = ' و ';
  static const String authPrivacy = 'سياسة الخصوصية';
  static const String authTermsSuffix = 'الخاصة بنا.';
}
