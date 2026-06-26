import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _orders = await OrderService.list();
    } catch (_) {}
    setState(() => _loading = false);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered': return AppColors.green;
      case 'cancelled': case 'refunded': return AppColors.red;
      case 'shipped': return Colors.purple;
      case 'processing': case 'confirmed': return Colors.blue;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات بعد', style: TextStyle(color: AppColors.muted)))
              : RefreshIndicator(
                  color: AppColors.gold,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final o = _orders[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('#${o.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: _statusColor(o.status).withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                                child: Text(o.statusLabel, style: TextStyle(color: _statusColor(o.status), fontSize: 11.5, fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('${o.itemsCount} منتج', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                              Text(o.totalFormatted, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gold)),
                            ]),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
