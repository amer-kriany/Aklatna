class BusinessTimeUtils {
  /// Returns true when the business is currently open, based on a single
  /// day's hours only. Does NOT account for yesterday's overnight spillover
  /// — use [isOpenNowWithOvernightCheck] for that.
  static bool isOpenNow(
    String openingTime,
    String closingTime,
  ) {
    final now = DateTime.now();

    final openMinutes = timeToMinutes(openingTime);
    final closeMinutes = timeToMinutes(closingTime);

    if (openMinutes == null || closeMinutes == null) {
      return false;
    }

    final nowMinutes = now.hour * 60 + now.minute;

    if (openMinutes == closeMinutes) {
      return true;
    }

    if (openMinutes < closeMinutes) {
      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    }

    return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
  }

  /// Correctly handles the case where yesterday's hours were overnight
  /// (close < open) and that window is still active right now, even if
  /// today's own hours say closed / not yet open.
static bool isOpenNowWithOvernightCheck({
  required bool todayActive,
  required String todayOpen,
  required String todayClose,
  required bool yesterdayActive,
  required String yesterdayOpen,
  required String yesterdayClose,
}) {
  final now = DateTime.now();
  final nowMinutes = now.hour * 60 + now.minute;

  // 1. Today's own window.
  if (todayActive) {
    final openMin = timeToMinutes(todayOpen);
    final closeMin = timeToMinutes(todayClose);

    if (openMin != null && closeMin != null) {
      if (openMin == closeMin) {
        return true; // 24h
      }

      if (openMin < closeMin) {
        // Normal same-day hours.
        if (nowMinutes >= openMin && nowMinutes < closeMin) {
          return true;
        }
      } else {
        // Overnight hours starting today — only the "from open time
        // onward today" part belongs to today. The early-morning part
        // (before open) belongs to YESTERDAY's spillover, checked below,
        // not today's own window.
        if (nowMinutes >= openMin) {
          return true;
        }
      }
    }
  }

  // 2. Yesterday's overnight spillover into this morning.
  if (yesterdayActive) {
    final openMin = timeToMinutes(yesterdayOpen);
    final closeMin = timeToMinutes(yesterdayClose);
    if (openMin != null && closeMin != null && openMin > closeMin) {
      if (nowMinutes < closeMin) {
        return true;
      }
    }
  }

  return false;
}

  static int? timeToMinutes(String value) {
    try {
      final parts = value.split(':');

      if (parts.length < 2) {
        return null;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        return null;
      }

      return hour * 60 + minute;
    } catch (_) {
      return null;
    }
  }
}