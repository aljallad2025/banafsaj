import '../models/cart_item.dart';
import 'api_service.dart';

class CartResult {
  final List<CartItem> items;
  final int itemCount;
  final double subtotal;
  final String subtotalFormatted;
  CartResult({required this.items, required this.itemCount, required this.subtotal, required this.subtotalFormatted});
}

class CartService {
  static Future<CartResult> get() async {
    final data = await ApiService.get('cart.php');
    return CartResult(
      items: List<CartItem>.from((data['items'] as List).map((i) => CartItem.fromJson(i))),
      itemCount: data['item_count'] ?? 0,
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      subtotalFormatted: data['subtotal_formatted'] ?? '',
    );
  }

  static Future<void> add(int productId, {int? variantId, int quantity = 1}) async {
    await ApiService.post('cart.php', {'product_id': productId, 'variant_id': variantId, 'quantity': quantity});
  }

  static Future<void> updateQuantity(int cartItemId, int quantity) async {
    await ApiService.put('cart.php', {'cart_item_id': cartItemId, 'quantity': quantity});
  }

  static Future<void> remove(int cartItemId) async {
    await ApiService.delete('cart.php', {'cart_item_id': cartItemId});
  }

  static Future<void> clear() async {
    await ApiService.delete('cart.php');
  }
}
