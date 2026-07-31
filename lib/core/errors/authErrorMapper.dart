import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps raw exceptions from the auth flow into friendly Arabic messages
/// for display in a SnackBar. Centralized here so SignInPage/SignUpPage
/// (and any future auth screen) all show consistent, correct messages
/// instead of raw exception.toString() dumps.
class AuthErrorMapper {
  const AuthErrorMapper._();

  static String map(Object error) {
    // ============================================================
    // SUPABASE AUTH EXCEPTIONS
    // ============================================================
    //
    // Supabase's AuthException.message comes back in English, with
    // fairly stable wording across versions. Matched via contains()
    // (case-insensitive) rather than exact equality since Supabase
    // sometimes appends extra detail to these messages.
    // ============================================================

    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return 'رقم الهاتف أو كلمة المرور غير صحيحة';
      }

      if (msg.contains('user already registered') ||
          msg.contains('already registered') ||
          msg.contains('already exists')) {
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      }

      if (msg.contains('email not confirmed')) {
        return 'يرجى تأكيد البريد الإلكتروني أولاً';
      }

      if (msg.contains('password should be at least')) {
        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
      }

      if (msg.contains('unable to validate email address') ||
          msg.contains('invalid email')) {
        return 'صيغة البريد الإلكتروني غير صحيحة';
      }

      if (msg.contains('email rate limit exceeded') ||
          msg.contains('rate limit')) {
        return 'محاولات كثيرة جداً، حاول لاحقاً';
      }

      if (msg.contains('network') || msg.contains('connection')) {
        return 'تحقق من اتصال الإنترنت وحاول مرة أخرى';
      }
         if (msg.contains('database error saving new user')) {
  return 'رقم الهاتف أو البريد الإلكتروني مستخدم بالفعل';
}

      // Unmatched AuthException — still better than raw English dump.
      return 'حدث خطأ أثناء المصادقة، حاول مرة أخرى';
    }

    // ============================================================
    // POSTGREST / DATABASE EXCEPTIONS
    // ============================================================
    //
    // e.g. profile row lookup failures unrelated to auth itself.
    // ============================================================

    if (error is PostgrestException) {
      return 'حدث خطأ في الاتصال بالخادم، حاول مرة أخرى';
    }

    // ============================================================
    // OUR OWN CUSTOM EXCEPTIONS (already Arabic, already friendly)
    // ============================================================
    //
    // AuthDatasource throws Exception('رقم الهاتف غير مسجل') and
    // Exception('تعذر العثور على الملف الشخصي') directly — these are
    // already correct, user-facing Arabic. Dart wraps them as
    // "Exception: <message>" when caught generically, so we strip
    // that prefix rather than re-mapping them into something generic.
    // ============================================================

    final raw = error.toString();

    if (raw.startsWith('Exception: ')) {
      final stripped = raw.substring('Exception: '.length);

      // Heuristic: if it already contains Arabic characters, trust it
      // as one of our own intentional messages and pass it through.
      final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(stripped);

      if (hasArabic) {
        return stripped;
      }
    }
 

    // ============================================================
    // FALLBACK
    // ============================================================
    //
    // Anything unrecognized (network-layer errors, unexpected nulls,
    // etc.) — never show the customer a raw stack trace or English
    // exception dump.
    // ============================================================

    return 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }
}