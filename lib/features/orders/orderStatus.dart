enum OrderStatus { pending, preparing, ready, outForDelivery, completed, cancelled }

// ============================================================
// SINGLE SOURCE OF TRUTH for "is this order ongoing/active".
//
// Every place in the app that needs to know whether an order is
// still active (checkout guard, MyOrdersPage tabs, bloc realtime
// unsubscribe logic) MUST use isOngoing/isHistory from here.
// Do NOT reimplement this switch anywhere else -- that's exactly
// how pending/preparing/ready/outForDelivery drifted out of sync
// across 3 different files before.
// ============================================================
extension OrderStatusX on OrderStatus {
  bool get isOngoing {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.preparing:
      case OrderStatus.ready:
      case OrderStatus.outForDelivery:
        return true;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return false;
    }
  }

  bool get isHistory =>
      this == OrderStatus.completed || this == OrderStatus.cancelled;
}