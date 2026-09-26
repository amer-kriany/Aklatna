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

    return orders.map(mapToEntity).toList();
  }

  @override
  Stream<OrderEntity> watchOrderStatus(String orderId) {
    return orderRemoteDatasource.watchOrderStatus(orderId).map(mapToEntity);
  }

  OrderEntity mapToEntity(OrderModel order) {
    return OrderEntity(
      id: order.id,
      orderNumber: order.orderNumber,
      createdAt: order.createdAt,

      businessId: order.businessId,
      customerId: order.customerId,
      customername: order.customername,
      customerPhone: order.customerPhone,

      items: order.items,

      deliveryAddress: order.deliveryAddress,
      deliveryLatitude: order.deliveryLatitude,
      deliveryLongitude: order.deliveryLongitude,
      description: order.description,

      businessLogo: order.businessLogo,
      businessName: order.businessName,

      totalPrice: order.totalPrice,

      orderType: order.orderType,
      orderStatus: order.orderStatus,

      scheduledFor: order.scheduledFor,

      estimatedPreparationTime: order.estimatedPreparationTime,

      
    );
  }

  OrderModel entityToModel(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      createdAt: entity.createdAt,

      businessId: entity.businessId,
      customerId: entity.customerId,
      customername: entity.customername,
      customerPhone: entity.customerPhone,

      items: entity.items,

      deliveryAddress: entity.deliveryAddress,
      deliveryLatitude: entity.deliveryLatitude,
      deliveryLongitude: entity.deliveryLongitude,
      description: entity.description,

      businessLogo: entity.businessLogo,
      businessName: entity.businessName,

      totalPrice: entity.totalPrice,

      orderType: entity.orderType,
      orderStatus: entity.orderStatus,

      scheduledFor: entity.scheduledFor,

      // Not sent when placing an order, but preserved for updates.
      estimatedPreparationTime: entity.estimatedPreparationTime,

    
    );
  }
}