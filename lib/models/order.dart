class OrderItem {
  final int productId;
  final String name;
  final String? variant;
  final int quantity;
  final double price;
  final String priceFormatted;
  final double total;
  final String totalFormatted;
  final String? image;

  OrderItem({required this.productId, required this.name, this.variant, required this.quantity, required this.price, required this.priceFormatted, required this.total, required this.totalFormatted, this.image});

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        productId: j['product_id'],
        name: j['name'] ?? '',
        variant: j['variant'],
        quantity: j['quantity'] ?? 1,
        price: (j['price'] ?? 0).toDouble(),
        priceFormatted: j['price_formatted'] ?? '',
        total: (j['total'] ?? 0).toDouble(),
        totalFormatted: j['total_formatted'] ?? '',
        image: j['image'],
      );
}

class Order {
  final int id;
  final String orderNumber;
  final String status;
  final String? paymentStatus;
  final String? paymentMethod;
  final double total;
  final String totalFormatted;
  final int itemsCount;
  final String createdAt;
  final List<OrderItem> items;
  final String? trackingNumber;
  final String? notes;

  Order({
    required this.id, required this.orderNumber, required this.status, this.paymentStatus, this.paymentMethod,
    required this.total, required this.totalFormatted, this.itemsCount = 0, required this.createdAt,
    this.items = const [], this.trackingNumber, this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        orderNumber: j['order_number'] ?? '',
        status: j['status'] ?? 'pending',
        paymentStatus: j['payment_status'],
        paymentMethod: j['payment_method'],
        total: (j['total'] ?? 0).toDouble(),
        totalFormatted: j['total_formatted'] ?? '',
        itemsCount: j['items_count'] ?? (j['items'] as List?)?.length ?? 0,
        createdAt: j['created_at'] ?? '',
        items: j['items'] != null ? List<OrderItem>.from((j['items'] as List).map((i) => OrderItem.fromJson(i))) : [],
        trackingNumber: j['tracking_number'],
        notes: j['notes'],
      );

  static const statusLabels = {
    'pending': 'بانتظار التأكيد',
    'confirmed': 'مؤكد',
    'processing': 'قيد التجهيز',
    'shipped': 'تم الشحن',
    'delivered': 'تم التسليم',
    'cancelled': 'ملغي',
    'refunded': 'مسترد',
  };

  String get statusLabel => statusLabels[status] ?? status;
}
