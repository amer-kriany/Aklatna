import 'package:flutter/material.dart';

/// Shared helpers for checking business opening hours.
/// Used by restaurant cards, "Open Now" homepage section, etc.
class BusinessTimeUtils {
  const BusinessTimeUtils._();

  /// Returns true if the current time falls within [openingTime] - [closingTime].
  /// Handles overnight hours too (e.g. 18:00 - 02:00).
  static bool isOpenNow(String openingTime, String closingTime) {
    final now = TimeOfDay.now();
    return isOpenAt(now, openingTime, closingTime);
  }

  /// Same as [isOpenNow] but for a specific [time] (useful for testing).
  static bool isOpenAt(TimeOfDay time, String openingTime, String closingTime) {
    final open = _parseTime(openingTime);
    final close = _parseTime(closingTime);

    final nowMinutes = time.hour * 60 + time.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    if (closeMinutes > openMinutes) {
      // Same-day hours, e.g. 09:00 - 23:00
      return nowMinutes >= openMinutes && nowMinutes <= closeMinutes;
    } else {
      // Overnight hours, e.g. 18:00 - 02:00
      return nowMinutes >= openMinutes || nowMinutes <= closeMinutes;
    }
  }

  static TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
  }
}
