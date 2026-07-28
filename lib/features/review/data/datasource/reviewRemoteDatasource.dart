import 'package:aklatna/features/review/data/model/reviewModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRemoteDatasource {
  final supabase = Supabase.instance.client;

  // ============================================================
  // SUBMIT REVIEW
  // ============================================================

  Future<void> submitReview(ReviewModel review) async {
    try {
      await supabase.from('reviews').insert(review.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================
  // CHECK IF ORDER ALREADY REVIEWED
  // ============================================================
  //
  // reviews.order_id has a UNIQUE constraint, so at most one row
  // can exist per order. maybeSingle() returns null if none found
  // instead of throwing.
  // ============================================================

  Future<bool> hasReviewForOrder(String orderId) async {
    try {
      final result = await supabase
          .from('reviews')
          .select('id')
          .eq('order_id', int.parse(orderId))
          .maybeSingle();

      return result != null;
    } catch (e) {
      rethrow;
    }
  }
}