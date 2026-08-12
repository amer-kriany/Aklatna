import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class WatchDriverOrdersUseCase {
  final OrderRepository repository;

  WatchDriverOrdersUseCase({required this.repository});

  Stream<void> call(String driverId) {
    return repository.watchDriverOrdersChanges(driverId);
  }
}