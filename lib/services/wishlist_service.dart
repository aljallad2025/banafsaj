import 'api_service.dart';

class WishlistItem {
  final int id;
  final String name;
  final String slug;
  final double price;
  final double currentPrice;
  final int discountPercent;
  final String priceFormatted;
  final String? mainImage;
  final int stock;

  WishlistItem({required this.id, required this.name, required this.slug, required this.price, required this.currentPrice, required this.discountPercent, required this.priceFormatted, this.mainImage, required this.stock});

  factory WishlistItem.fromJson(Map<String, dynamic> j) => WishlistItem(
        id: j['id'], name: j['name'] ?? '', slug: j['slug'] ?? '',
        price: (j['price'] ?? 0).toDouble(), currentPrice: (j['current_price'] ?? 0).toDouble(),
        discountPercent: j['discount_percent'] ?? 0, priceFormatted: j['price_formatted'] ?? '',
        mainImage: j['main_image'], stock: j['stock'] ?? 0,
      );
}

class WishlistService {
  static Future<List<WishlistItem>> list() async {
    final data = await ApiService.get('wishlist.php');
    return List<WishlistItem>.from((data as List).map((i) => WishlistItem.fromJson(i)));
  }

  static Future<bool> toggle(int productId) async {
    final data = await ApiService.post('wishlist.php', {'product_id': productId});
    return data['in_wishlist'] ?? false;
  }

  static Future<void> remove(int productId) async {
    await ApiService.delete('wishlist.php', {'product_id': productId});
  }
}
