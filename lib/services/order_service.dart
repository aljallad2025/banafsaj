import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  static Future<List<Order>> list({int page = 1}) async {
    final data = await ApiService.get('orders.php?page=$page');
    return List<Order>.from((data['orders'] as List).map((o) => Order.fromJson(o)));
  }

  static Future<Order> detail(int id) async {
    final data = await ApiService.get('orders.php?id=$id');
    return Order.fromJson(data);
  }

  static Future<Map<String, dynamic>> placeOrder({
    int? addressId,
    Map<String, dynamic>? shippingAddress,
    required double shippingCost,
    String? shippingCompany,
    required String paymentMethod,
    String? couponCode,
    String? notes,
  }) async {
    return await ApiService.post('orders.php', {
      if (addressId != null) 'address_id': addressId,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      'shipping_cost': shippingCost,
      if (shippingCompany != null) 'shipping_company': shippingCompany,
      'payment_method': paymentMethod,
      if (couponCode != null) 'coupon_code': couponCode,
      'notes': notes ?? '',
    });
  }

  static Future<Map<String, dynamic>> validateCoupon(String code, double subtotal) async {
    return await ApiService.post('coupon_validate.php', {'code': code, 'subtotal': subtotal});
  }
}
