class CartItem {
  final int cartItemId;
  final int productId;
  final String name;
  final String slug;
  final String? image;
  final int? variantId;
  final String? variant;
  final double price;
  final String priceFormatted;
  final int quantity;
  final double total;
  final String totalFormatted;
  final int stock;

  CartItem({
    required this.cartItemId, required this.productId, required this.name, required this.slug,
    this.image, this.variantId, this.variant, required this.price, required this.priceFormatted,
    required this.quantity, required this.total, required this.totalFormatted, required this.stock,
  });

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        cartItemId: j['cart_item_id'],
        productId: j['product_id'],
        name: j['name'] ?? '',
        slug: j['slug'] ?? '',
        image: j['image'],
        variantId: j['variant_id'],
        variant: j['variant'],
        price: (j['price'] ?? 0).toDouble(),
        priceFormatted: j['price_formatted'] ?? '',
        quantity: j['quantity'] ?? 1,
        total: (j['total'] ?? 0).toDouble(),
        totalFormatted: j['total_formatted'] ?? '',
        stock: j['stock'] ?? 0,
      );
}
