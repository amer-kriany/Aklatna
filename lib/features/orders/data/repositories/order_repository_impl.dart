import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource orderRemoteDatasource;
  OrderRepositoryImpl({required this.orderRemoteDatasource});
  @override
  Future<bool> placeOrder(OrderModel order) async {
    return await orderRemoteDatasource.placeOrder(order);
  }

  @override
  Future<List<OrderEntity>> customerOrders(String customerId) async {
    final orders = await orderRemoteDatasource.customerOrders(customerId);
    return orders.map((e)=>mapToEntity(e)).toList() ;
  }
}

 OrderEntity mapToEntity(OrderModel order) {
  return OrderEntity(
    businessId: order.businessId,
    customerId: order.customerId,
    customerUsername: order.customerUsername,
    customerPhone: order.customerPhone,
    items: order.items,
    totalPrice: order.totalPrice,
    orderType: order.orderType,
  );
}
