class BusinessTimeUtils {
  /// Returns true when the business is currently open.
  ///
  /// Examples:
  /// 09:00 -> 17:00
  /// 18:00 -> 04:00 (overnight)
  static bool isOpenNow(
    String openingTime,
    String closingTime,
  ) {
    final now = DateTime.now();

    final openMinutes = _timeToMinutes(openingTime);
    final closeMinutes = _timeToMinutes(closingTime);

    if (openMinutes == null || closeMinutes == null) {
      return false;
    }

    final nowMinutes =
        now.hour * 60 + now.minute;

    // ============================================================
    // SAME OPEN/CLOSE TIME
    // ============================================================
    //
    // 00:00 -> 00:00 could mean 24 hours.
    //
    if (openMinutes == closeMinutes) {
      return true;
    }

    // ============================================================
    // NORMAL BUSINESS HOURS
    // ============================================================
    //
    // Example:
    // 09:00 -> 17:00
    //
    // Open:
    // 09:00 <= now < 17:00
    //
    if (openMinutes < closeMinutes) {
      return nowMinutes >= openMinutes &&
          nowMinutes < closeMinutes;
    }

    // ============================================================
    // OVERNIGHT BUSINESS HOURS
    // ============================================================
    //
    // Example:
    // 18:00 -> 04:00
    //
    // Open:
    // 18:00 -> 23:59
    // OR
    // 00:00 -> 03:59
    //
    return nowMinutes >= openMinutes ||
        nowMinutes < closeMinutes;
  }

  static int? _timeToMinutes(String value) {
    try {
      final parts = value.split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        return null;
      }

      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }
}