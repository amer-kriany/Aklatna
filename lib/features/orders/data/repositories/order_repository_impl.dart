import 'dart:math';

import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource orderRemoteDatasource;
  OrderRepositoryImpl({required this.orderRemoteDatasource});
  @override
  Future<void> placeOrder(OrderEntity order) async {
    await orderRemoteDatasource.placeOrder(entityToModel(order));
  }

  @override
  Future<List<OrderEntity>> customerOrders(String customerId) async {
    final orders = await orderRemoteDatasource.customerOrders(customerId);
    return orders.map((e) => mapToEntity(e)).toList();
  }

  @override
  Stream<OrderEntity> watchOrderStatus(String orderId) {
    return orderRemoteDatasource
        .watchOrderStatus(orderId)
        .map((e) => mapToEntity(e));
  }
}

OrderEntity mapToEntity(OrderModel order) {
  return OrderEntity(
    businessId: order.businessId,
    customerId: order.customerId,
    customername: order.customername,
    customerPhone: order.customerPhone,
    items: order.items,
    totalPrice: order.totalPrice,
    orderType: order.orderType,
    id: order.id,
    orderNumber: order.orderNumber,
    createdAt: order.createdAt,
    orderStatus: order.orderStatus,
    scheduledFor: order.scheduledFor,
    description: order.description,
    businessLogo: order.businessLogo,
    businessName: order.businessName,
    deliveryAddress: order.deliveryAddress,
    estimatedPreparationTime: order.estimatedPreparationTime

  );
}

OrderModel entityToModel(OrderEntity entity) {
  return OrderModel(
    businessId: entity.businessId,
    customerId: entity.customerId,
    customername: entity.customername,
    customerPhone: entity.customerPhone,
    items: entity.items,
    totalPrice: entity.totalPrice,
    orderType: entity.orderType,
    id: entity.id,
    orderNumber: entity.orderNumber,
    createdAt: entity.createdAt,
    orderStatus: entity.orderStatus,
    scheduledFor: entity.scheduledFor,
    description: entity.description,
    businessLogo: entity.businessLogo,
    businessName: entity.businessName,
    deliveryAddress: entity.deliveryAddress,
    
  );
}
