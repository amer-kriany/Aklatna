import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/models/order_model.dart';
import 'package:aklatna/features/orders/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource orderRemoteDatasource;
  OrderRepositoryImpl({required this.orderRemoteDatasource});
  @override
  Future<bool> placeOrder(OrderModel order) async {
    return await orderRemoteDatasource.placeOrder(order) ;
  }
}
