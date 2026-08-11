import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class WatchAvailableOrdersUseCase {
  final OrderRepository repository;

  WatchAvailableOrdersUseCase({required this.repository});

  Stream<void> call() {
    return repository.watchAvailableOrdersChanges();
  }
}