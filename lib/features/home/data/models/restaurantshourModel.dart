class RestaurantHourModel {
  final String id;
  final String businessId; // NOTE: stored as `user_id` in Supabase — a
  // naming mistake from the dashboard side, NOT an actual auth user
  // reference. Renamed here so nothing downstream has to know about it.
  final int dayOfWeek; // 0 = Monday ... 6 = Sunday (per dashboard convention)
  final String openTime;
  final String closeTime;
  final bool isClosed;

  RestaurantHourModel({
    required this.id,
    required this.businessId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory RestaurantHourModel.fromSupabase(Map<String, dynamic> row) {
    String asStringOrEmpty(dynamic value) => value?.toString() ?? '';

    int asIntOrZero(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    bool asBoolOrFalse(dynamic value) {
      if (value is bool) return value;
      return value?.toString() == 'true';
    }

    return RestaurantHourModel(
      id: asStringOrEmpty(row['id']),
      businessId: asStringOrEmpty(row['user_id']),
      dayOfWeek: asIntOrZero(row['day_of_week']),
      // time columns come back as "HH:mm:ss" from Postgres `time` type —
      // truncate to "HH:mm" to match BusinessTimeUtils' expected format.
      openTime: asStringOrEmpty(row['open_time']).length >= 5
          ? asStringOrEmpty(row['open_time']).substring(0, 5)
          : asStringOrEmpty(row['open_time']),
      closeTime: asStringOrEmpty(row['close_time']).length >= 5
          ? asStringOrEmpty(row['close_time']).substring(0, 5)
          : asStringOrEmpty(row['close_time']),
      isClosed: asBoolOrFalse(row['is_closed']),
    );
  }
}