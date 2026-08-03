class SupabaseConstants {
  SupabaseConstants._();

  // Table Names
  static const String profilesTable = 'profiles';
  static const String restaurantsTable = 'restaurants';
  static const String menuCategoriesTable = 'menu_categories';
  static const String menuItemsTable = 'menu_items';
  static const String ordersTable = 'orders';
  static const String orderItemsTable = 'order_items';
  static const String jobPostsTable = 'job_posts';
  static const String favoritesTable = 'favorites';
  static const String reviewsTable = 'reviews';

  // Storage Buckets
  static const String userAvatarsBucket = 'avatars';
  static const String restaurantImagesBucket = 'restaurant-images';
  static const String menuItemImagesBucket = 'menu-item-images';

  // Common Column Names (Optional but helpful for consistency)
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colUserId = 'user_id';
}
