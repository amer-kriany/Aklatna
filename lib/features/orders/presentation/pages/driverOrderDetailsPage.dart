import 'dart:async';

import 'package:aklatna/core/constants/app_spacing.dart';
import 'package:aklatna/core/constants/app_text_style.dart';
import 'package:aklatna/core/theme/app_colors.dart';
import 'package:aklatna/features/home/presentation/bloc/business_bloc.dart';
import 'package:aklatna/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:aklatna/features/orders/data/repositories/order_repository_impl.dart';
import 'package:aklatna/features/orders/domain/entities/order_entity.dart';
import 'package:aklatna/features/orders/orderStatus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aklatna/features/orders/presentation/widgets/orderStatusUi.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverOrderDetailsPage extends StatefulWidget {
  const DriverOrderDetailsPage({super.key, required this.order});

  final OrderEntity order;

  @override
  State<DriverOrderDetailsPage> createState() =>
      _DriverOrderDetailsPageState();
}

class _DriverOrderDetailsPageState extends State<DriverOrderDetailsPage> {
  late OrderEntity _order;
  StreamSubscription<OrderEntity>? _subscription;

  @override
  void initState() {
    super.initState();
    _order = widget.order;

    // Scoped realtime for just this order -- deliberately not routed
    // through the shared OrderBloc, since that bloc's single `state`
    // is already holding the driver's list (home/orders pages stay
    // mounted underneath this pushed page); emitting a point-update
    // there would blank out those screens. Same "construct fresh
    // repo/usecase per route" pattern already used elsewhere in the
    // app for scoped page data.
    final repo = OrderRepositoryImpl(
      orderRemoteDatasource: OrderRemoteDatasource(),
    );

    _subscription = repo.watchOrderStatus(_order.id!).listen((updated) {
      if (!mounted) return;

      final justCancelled = _order.orderStatus != OrderStatus.cancelled &&
          updated.orderStatus == OrderStatus.cancelled;

      setState(() => _order = updated);

      if (justCancelled) {
        _showCancelledDialog();
      }
    });
  }

  void _showCancelledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تم إلغاء الطلب'),
            content: const Text('تم إلغاء هذا الطلب. لم يعد بإمكانك المتابعة به.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('حسناً'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  String? _businessAddress(BuildContext context) {
    final businessState = context.read<BusinessBloc>().state;
    if (businessState is! BusinessFetched) return null;

    for (final business in businessState.businesses) {
      if (business.id == _order.businessId) {
        return _shortAddress(business.adress);
      }
    }
    return null;
  }

  // Drops the country/province tail ("سوريا", "محافظة ...") so this
  // shows just the local part instead of the full address.
  String? _shortAddress(String? fullAddress) {
    if (fullAddress == null || fullAddress.trim().isEmpty) return null;

    final parts = fullAddress
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !e.contains('سوريا') && !e.contains('محافظة'))
        .toList();

    return parts.isEmpty ? null : parts.join('، ');
  }

  Future<void> _openCustomerLocationInMaps(BuildContext context) async {
    final Uri mapsUri;

    if (_order.deliveryLatitude != null && _order.deliveryLongitude != null) {
      mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_order.deliveryLatitude},${_order.deliveryLongitude}',
      );
    } else if (_order.deliveryAddress != null &&
        _order.deliveryAddress!.isNotEmpty) {
      // Fallback for orders placed before lat/lng was added to the
      // schema -- search by the address text instead.
      mapsUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_order.deliveryAddress!)}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد موقع محدد لهذا الطلب')),
      );
      return;
    }

    final launched = await launchUrl(
      mapsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد تطبيق خرائط مثبت')),
      );
    }
  }

  Future<void> _callCustomer(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _order.customerPhone);
    final launched = await launchUrl(uri);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح تطبيق الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAddress = _businessAddress(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('طلب #${_order.orderNumber ?? ''}', style: AppTextStyles.h4)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
          children: [
            _SectionCard(
              title: 'حالة الطلب',
              children: [_InfoRow(label: 'الحالة', value: orderStatusLabel(_order.orderStatus))],
            ),
            const SizedBox(height: AppSpacing.sm),

            _SectionCard(
              title: 'المطعم',
              children: [
                _InfoRow(label: 'الاسم', value: _order.businessName ?? '—'),
                _InfoRow(label: 'العنوان', value: businessAddress ?? 'غير متوفر'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            _SectionCard(
              title: 'الزبون',
              children: [
                _InfoRow(label: 'الاسم', value: _order.customername),
                _InfoRow(label: 'الهاتف', value: _order.customerPhone),
                _InfoRow(
                  label: 'عنوان التوصيل',
                  value: _order.deliveryAddress ?? 'استلام من المطعم',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callCustomer(context),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('اتصال بالزبون'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _order.orderType.name == 'pickup'
                        ? null
                        : () => _openCustomerLocationInMaps(context),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('فتح الموقع'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            _SectionCard(
              title: 'الطلب',
              children: [
                for (final item in _order.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity} × ${item.nameAr}', style: AppTextStyles.regularMedium),
                        Text('${item.price * item.quantity} ل.س', style: AppTextStyles.regularMedium),
                      ],
                    ),
                  ),
                const Divider(),
                _InfoRow(
                  label: 'رسوم التوصيل',
                  value: '${_order.deliveryFee} ل.س',
                ),
                _InfoRow(
                  label: 'الإجمالي',
                  value: '${_order.totalPrice} ل.س',
                  bold: true,
                ),
              ],
            ),

            if (_order.description != null && _order.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _SectionCard(
                title: 'ملاحظات',
                children: [Text(_order.description!)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h4),
            const SizedBox(height: AppSpacing.xs),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.regularSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.bodyMedium
                : AppTextStyles.regularMedium,
          ),
        ],
      ),
    );
  }
}